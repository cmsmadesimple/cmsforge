namespace :db do      
    desc "Dumps database to file in the db directory."
    task(:dump => :environment) do
      db_config = ActiveRecord::Base.configurations[Rails.env]
      unless db_config['password'].blank?
        sh "mysqldump -u #{db_config['username']} -p#{db_config['password']} -Q --add-drop-table --add-locks #{db_config['database']} > #{Rails.root}/db/#{db_config['database']}.sql"     
      else
        sh "mysqldump -u #{db_config['username']} -Q --add-drop-table --add-locks #{db_config['database']} > #{Rails.root}/db/#{db_config['database']}.sql"     
      end
    end
    desc "Loads data from a previous mysql dump -- will drop existing table!"
    task(:load => :environment) do
      db_config = ActiveRecord::Base.configurations[Rails.env]    
      unless db_config['password'].blank?
        sh "mysql -u #{db_config['username']} -p#{db_config['password']} #{db_config['database']} <  #{Rails.root}/db/#{db_config['database']}.sql"
      else
        sh "mysql -u #{db_config['username']} #{db_config['database']} <  #{Rails.root}/db/#{db_config['database']}.sql"
      end
    end
end
