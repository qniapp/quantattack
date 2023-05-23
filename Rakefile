# frozen_string_literal: true

require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'rake/clean'

def version
  File.read('data/version.txt').chomp
end

def carts
  %w[title tutorial endless rush vs_qpu qpu_vs_qpu vs_human]
end

def p8_path(name, build = :debug)
  "build/v#{version}_#{build}/quantattack_#{name}.p8"
end

def cart_main_source(name)
  "src/main_#{name}.lua"
end

def cart_specific_sources(name)
  FileList["src/#{name}/*.lua"]
end

def common_lib_sources
  FileList['src/lib/**/*.lua']
end

def cart_sources(name)
  FileList[cart_main_source(name)] + cart_specific_sources(name) + common_lib_sources
end

def cart_data(name)
  "data/builtin_data_#{name}.p8"
end

def cart_sources_and_data(name)
  cart_sources(name) + FileList[cart_data(name)]
end

def build_cartridge_command(name, build = :debug, *symbols)
  symbols_option = if build == :debug
                     ([:tostring, :dump, name] + symbols).uniq.join(',')
                   else
                     ([name] + symbols).join(',')
                   end
  "./pico-boots/scripts/build_cartridge.sh \"#{File.join(__dir__, './src')}\" main_#{name}.lua " \
     "-d \"#{File.join(__dir__, "data/builtin_data_#{name}.p8")}\" " \
     "-M \"#{File.join(__dir__, 'data/metadata.p8')}\" " \
     "-a yasuhito -t \"quantattack v#{version} (#{name})\" " \
     "-p \"#{File.join(__dir__, "build/v#{version}_#{build}")}\" " \
     "-o quantattack_#{name} " \
     "-s \"#{symbols_option}\" " \
     '--minify-level 1'
end

def build_single_cartridge_sh
  './scripts/build_single_cartridge.sh'
end

def install_single_cartridge_sh
  './scripts/install_single_cartridge.sh'
end

def pmd_sh
  '~/Documents/GitHub/pmd-bin-6.52.0/bin/run.sh'
end

desc '現在のバージョンを表示'
task :version do
  puts version
end

task default: 'build:debug'

desc 'リリース'
task release: 'build:release' do
  sh './scripts/export_and_patch_cartridge_release.sh'
end

desc 'data カートを起動'
task :data do
  sh '/Applications/PICO-8.app/Contents/MacOS/pico8 -run data.p8 -screenshot_scale 4 -gif_scale 4'
end

task :test do
  sh './scripts/test.sh'
end

task 'test:solo' do
  sh './scripts/test.sh -m solo'
end

desc 'デバッグビルド'
task 'build:debug' => carts

desc 'リリースビルド'
task 'build:release' => carts.map { |each| "#{each}:release" }

carts.each do |each|
  file cart_data(each) => 'data.p8' do
    cp 'data.p8', cart_data(each)
  end
end

task title: p8_path('title')
file p8_path('title') => cart_sources_and_data('title') do
  sh build_cartridge_command(:title)
  sh "#{install_single_cartridge_sh} title debug"
end

task tutorial: p8_path('tutorial')
file p8_path('tutorial') => cart_sources_and_data('tutorial') do
  sh build_cartridge_command(:tutorial)
  sh "#{install_single_cartridge_sh} tutorial debug"
end

task endless: p8_path('endless')
file p8_path('endless') => cart_sources_and_data('endless') do
  sh build_cartridge_command(:endless, :debug, :sash)
  sh "#{install_single_cartridge_sh} endless debug"
end

task rush: p8_path('rush')
file p8_path('rush') => cart_sources_and_data('rush') do
  sh build_cartridge_command(:rush, :debug, :sash)
  sh "#{install_single_cartridge_sh} rush debug"
end

task vs_qpu: p8_path('vs_qpu')
file p8_path('vs_qpu') => cart_sources_and_data('vs_qpu') do
  sh build_cartridge_command(:vs_qpu)
  sh "#{install_single_cartridge_sh} vs_qpu debug"
end

task qpu_vs_qpu: p8_path('qpu_vs_qpu')
file p8_path('qpu_vs_qpu') => cart_sources_and_data('qpu_vs_qpu') do
  sh build_cartridge_command(:qpu_vs_qpu)
  sh "#{install_single_cartridge_sh} qpu_vs_qpu debug"
end

task vs_human: p8_path('vs_human')
file p8_path('vs_human') => cart_sources_and_data('vs_human') do
  sh build_cartridge_command(:vs_human)
  sh "#{install_single_cartridge_sh} vs_human debug"
end

task 'title:release' => p8_path('title', :release)
file p8_path('title', :release) => cart_sources_and_data('title') do
  sh build_cartridge_command(:title, :release)
  sh "#{install_single_cartridge_sh} title release"
end

task 'tutorial:release' => p8_path('tutorial', :release)
file p8_path('tutorial', :release) => cart_sources_and_data('tutorial') do
  sh build_cartridge_command(:tutorial, :release)
  sh "#{install_single_cartridge_sh} tutorial release"
end

task 'endless:release' => p8_path('endless', :release)
file p8_path('endless', :release) => cart_sources_and_data('endless') do
  sh build_cartridge_command(:endless, :release, :sash)
  sh "#{install_single_cartridge_sh} endless release"
end

task 'rush:release' => p8_path('rush', :release)
file p8_path('rush', :release) => cart_sources_and_data('rush') do
  sh build_cartridge_command(:rush, :release, :sash)
  sh "#{install_single_cartridge_sh} rush release"
end

task 'vs_qpu:release' => p8_path('vs_qpu', :release)
file p8_path('vs_qpu', :release) => cart_sources_and_data('vs_qpu') do
  sh build_cartridge_command(:vs_qpu, :release)
  sh "#{install_single_cartridge_sh} vs_qpu release"
end

task 'qpu_vs_qpu:release' => p8_path('qpu_vs_qpu', :release)
file p8_path('qpu_vs_qpu', :release) => cart_sources_and_data('qpu_vs_qpu') do
  sh build_cartridge_command(:qpu_vs_qpu, :release)
  sh "#{install_single_cartridge_sh} qpu_vs_qpu release"
end

task 'vs_human:release' => p8_path('vs_human', :release)
file p8_path('vs_human', :release) => cart_sources_and_data('vs_human') do
  sh build_cartridge_command(:vs_human, :release)
  sh "#{install_single_cartridge_sh} vs_human release"
end

carts.each do |each|
  CLOBBER.include p8_path(each)
  CLOBBER.include p8_path(each, :release)
end

desc 'title カートを起動'
task run: 'build:debug' do
  sh "/Applications/PICO-8.app/Contents/MacOS/pico8 -run #{p8_path 'title'} -screenshot_scale 4 -gif_scale 4"
end

task count: 'build:debug' do
  shrinko8 = 'python ~/Documents/GitHub/shrinko8/shrinko8.py'

  carts.each do |each|
    output = `#{shrinko8} #{p8_path each} --parsable-count --count`
    if /count:None:tokens:(\d+)/=~ output
      tokens = Regexp.last_match(1).to_i

      puts "#{each}: #{tokens} (#{(tokens / 8192.0 * 100).round(1)} %)"
    else
      warn 'Invalid output'
    end
  end
end

task :dupe do
  sh "#{pmd_sh} cpd --dir src/ --language lua --minimum-tokens 10"
end
