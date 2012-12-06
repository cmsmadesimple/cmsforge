maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Sets up ruby"
version           "0.0.1"
recipe            "ruby", "Sets up ruby -- needs refactoring"

%w{ ubuntu debian }.each do |os|
  supports os
end
