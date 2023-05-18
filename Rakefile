# frozen_string_literal: true

require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)

version = File.read("data/version.txt").chomp

task :default do
  sh './scripts/build_and_install_all_cartridges.sh'
end

task :release do
  sh './scripts/build_and_install_all_cartridges.sh release'
  sh './scripts/export_and_patch_cartridge_release.sh'
end

task :title do
  sh './scripts/build_single_cartridge.sh title'
  sh './scripts/install_single_cartridge.sh title debug'
end

task :tutorial do
  sh './scripts/build_single_cartridge.sh tutorial'
  sh './scripts/install_single_cartridge.sh tutorial debug'
end

task :endless do
  sh './scripts/build_single_cartridge.sh endless'
  sh './scripts/install_single_cartridge.sh endless debug'
end

task :rush do
  sh './scripts/build_single_cartridge.sh rush'
  sh './scripts/install_single_cartridge.sh rush debug'
end

task :vs_qpu do
  sh './scripts/build_single_cartridge.sh vs_qpu'
  sh './scripts/install_single_cartridge.sh vs_qpu debug'
end

task :qpu_vs_qpu do
  sh './scripts/build_single_cartridge.sh qpu_vs_qpu'
  sh './scripts/install_single_cartridge.sh qpu_vs_qpu debug'
end

task :vs_human do
  sh './scripts/build_single_cartridge.sh vs_human'
  sh './scripts/install_single_cartridge.sh vs_human debug'
end

task :run do
  sh "/Applications/PICO-8.app/Contents/MacOS/pico8 -run build/v#{version}_debug/quantattack_title.p8 -screenshot_scale 4 -gif_scale 4"
end

task :data do
  sh '/Applications/PICO-8.app/Contents/MacOS/pico8 -run data.p8 -screenshot_scale 4 -gif_scale 4'
end

task :test do
  sh './scripts/test.sh'
end

task "test:solo" do
  sh './scripts/test.sh -m solo'
end

task :count do
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_title.p8 --count"
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_tutorial.p8 --count"
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_endless.p8 --count"
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_rush.p8 --count"
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_vs_qpu.p8 --count"
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_qpu_vs_qpu.p8 --count"
  sh "python ~/Documents/GitHub/shrinko8/shrinko8.py build/v#{version}_debug/quantattack_vs_human.p8 --count"
end

task :dupe do
  sh '~/Documents/GitHub/pmd-bin-6.52.0/bin/run.sh cpd --dir src/ --exclude src/**/*_utest.lua --language lua --minimum-tokens 10'
end
