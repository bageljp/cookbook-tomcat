define :tomcat_setup do

  case node['tomcat']['version']
  when "6"
    tomcat_version = node['tomcat']['6']['version']
    tarball_url = node['tomcat']['6']['url']
  when "7"
    tomcat_version = node['tomcat']['7']['version']
    tarball_url = node['tomcat']['7']['url']
  end

  base_name = "apache-tomcat-#{tomcat_version}"

  bash "install tomcat" do
    user "root"
    group "root"
    cwd "/usr/local/src"
    code <<-EOC
      rm -f #{base_name}.tar.gz
      curl -skOL #{tarball_url}
      rm -rf #{base_name}
      gzip -dc #{base_name}.tar.gz | tar xf -
      rm -rf #{node['tomcat']['root_dir']}/#{base_name}#{params[:name]}
      mv #{base_name} #{node['tomcat']['root_dir']}/#{base_name}#{params[:name]}
      cd #{node['tomcat']['root_dir']}
      ln -sf #{base_name}#{params[:name]} tomcat#{params[:name]}
      chown #{node['tomcat']['user']}:#{node['tomcat']['group']} -R #{node['tomcat']['root_dir']}/#{base_name}#{params[:name]}
      chown #{node['tomcat']['user']}:#{node['tomcat']['group']} -h #{node['tomcat']['root_dir']}/tomcat#{params[:name]}
    EOC
    creates "#{node['tomcat']['root_dir']}/tomcat#{params[:name]}/bin/catalina.sh"
  end

  if node['tomcat']['conf']['template_dir'].nil?
    # node['tomcat']['conf']['template_dir']が設定されていない場合
    template "#{node['tomcat']['root_dir']}/tomcat#{params[:name]}/bin/setenv.sh" do
      owner "#{node['tomcat']['user']}"
      group "#{node['tomcat']['group']}"
      mode 00644
      source "setenv#{params[:name]}.sh.erb"
      notifies :restart, "service[tomcat#{params[:name]}]"
    end
    
    template "#{node['tomcat']['root_dir']}/tomcat#{params[:name]}/bin/catalina.sh" do
      owner "#{node['tomcat']['user']}"
      group "#{node['tomcat']['group']}"
      mode 00755
      source "catalina#{node['tomcat']['version']}.sh.erb"
    end
    
    template "#{node['tomcat']['root_dir']}/tomcat#{params[:name]}/conf/server.xml" do
      owner "#{node['tomcat']['user']}"
      group "#{node['tomcat']['group']}"
      mode 00644
      source "server#{node['tomcat']['version']}#{params[:name]}.xml.erb"
      notifies :restart, "service[tomcat#{params[:name]}]"
    end
  else
    # node['tomcat']['conf']['template_dir']が設定されている場合
    # ディレクトリ内のconfを再帰的に取得
    conf_dir = File.join(Chef::Config[:cookbook_path].select{|elem| /cookbooks-3/ =~ elem}, "/tomcat/templates/default/", node['tomcat']['conf']['template_dir'], params[:name])
    Dir.chdir conf_dir
    confs = Dir::glob("**/*")
  
    # 取得したファイル一式を展開していく
    confs.each do |t|
      if File::ftype("#{conf_dir}/#{t}") == "file" && File.extname("#{conf_dir}/#{t}")  == ".sh"
        template "#{node['tomcat']['root_dir']}/tomcat#{params[:name]}/#{t}" do
          owner "#{node['tomcat']['user']}"
          group "#{node['tomcat']['group']}"
          mode 00755
          source "#{node['tomcat']['conf']['template_dir']}/#{t}"
          notifies :restart, "service[tomcat#{params[:name]}]"
        end
      elsif File::ftype("#{conf_dir}/#{t}") == "file"
        template "#{node['tomcat']['root_dir']}/tomcat#{params[:name]}/#{t}" do
          owner "#{node['tomcat']['user']}"
          group "#{node['tomcat']['group']}"
          mode 00644
          source "#{node['tomcat']['conf']['template_dir']}/#{t}"
          notifies :restart, "service[tomcat#{params[:name]}]"
        end
      end
    end
  end
  
  template "/etc/init.d/tomcat#{params[:name]}" do
    owner "root"
    group "root"
    mode 00755
    source "tomcat.erb"
  end
  
  template "/etc/security/limits.d/90-tomcat#{params[:name]}.conf" do
    owner "root"
    group "root"
    mode 00644
    source "limits.conf.erb"
    notifies :restart, "service[tomcat#{params[:name]}]"
  end
  
  service "tomcat#{params[:name]}" do
    supports :status => true, :restart => true, :reload => false
    action [ :enable, :start ]
  end

end
