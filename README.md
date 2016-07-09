What's ?
===============
chef で使用する Tomcat の cookbook です。

Usage
-----
cookbook なので berkshelf で取ってきて使いましょう。

* Berksfile
```ruby
source "https://supermarket.chef.io"

cookbook "tomcat", git: "https://github.com/bageljp/cookbook-tomcat.git"
```

```
berks vendor
```

#### Role and Environment attributes

* sample_role.rb
```ruby
override_attributes(
  "tomcat" => {
    "suffixes" => [
      "_beacon",
      "_api",
      "_solr"
    ],
    "user" => "user_name",
    "group" => "group_name",
    "version" => "7",
    "conf" => {
      "template_dir" => "conf_sample"
    }
  }
)
```

Recipes
----------

#### tomcat::default
suffixes 分だけ Tomcat をインストールして設定を行う。  

Attributes
----------

主要なやつのみ。

#### tomcat::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['tomcat']['suffixes']</tt></td>
    <td>array string</td>
    <td>Tomcatを複数インストールする場合に配列形式でsuffixを指定する。</td>
  </tr>
  <tr>
    <td><tt>['tomcat']['conf']['template_dir']</tt></td>
    <td>string</td>
    <td>``templates/default/['nginx']['conf']['template_dir']#{suffix}`` にある設定ファイル一式を適用する場合に指定する。</td>
  </tr>
</table>

