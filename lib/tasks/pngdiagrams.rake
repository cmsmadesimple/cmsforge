namespace :doc do
  namespace :pngdiagram do
    task :models do
      sh "railroad -i -l -a -m -M | dot -Tpng > doc/models.png"
    end

    task :controllers do
      sh "railroad -i -l -C | neato -Tpng > doc/controllers.png"
    end
  end

  task :pngdiagrams => %w(pngdiagram:models pngdiagram:controllers)
end
