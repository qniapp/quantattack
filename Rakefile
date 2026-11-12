# frozen_string_literal: true

require 'rake/clean'

# Tool paths. Override with environment variables, e.g. PICO8=/opt/pico-8/pico8 rake run
PICO8 = ENV.fetch('PICO8') do
  RUBY_PLATFORM.include?('darwin') ? '/Applications/PICO-8.app/Contents/MacOS/pico8' : 'pico8'
end
SHRINKO8 = ENV.fetch('SHRINKO8', 'shrinko8')
LUACHECK = ENV.fetch('LUACHECK', 'luacheck')
PMD = ENV.fetch('PMD', 'pmd')

def version
  File.read('data/version.txt').chomp
end

def carts
  File.readlines('data/cartridges.txt', chomp: true).reject(&:empty?)
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

def build_cartridge_command(name, build = :debug)
  "python3 scripts/build_cart.py #{name} #{build} #{p8_path(name, build)}"
end

def install_single_cartridge_sh
  './scripts/install_single_cartridge.sh'
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

desc 'data カートを起動 (スプライトと音の編集用)'
task :data do
  sh "#{PICO8} -run data.p8 -screenshot_scale 4 -gif_scale 4"
end

desc 'ユニットテスト'
task :test do
  sh './scripts/test.sh'
end

desc 'solo タグのついたユニットテストだけ実行'
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

  %i[debug release].each do |build|
    task_name = build == :debug ? each : "#{each}:release"

    task task_name => p8_path(each, build)
    file p8_path(each, build) => cart_sources_and_data(each) do
      sh build_cartridge_command(each, build)
      sh "#{install_single_cartridge_sh} #{each} #{build}"
    end

    CLOBBER.include p8_path(each, build)
  end
end

desc 'title カートを起動'
task run: 'build:debug' do
  sh "#{PICO8} -run #{p8_path 'title'} -screenshot_scale 4 -gif_scale 4"
end

desc '各カートのトークン数を表示'
task count: 'build:debug' do
  carts.each do |each|
    output = `#{SHRINKO8} #{p8_path each} --parsable-count --count`
    if /count:None:tokens:(\d+)/ =~ output
      tokens = Regexp.last_match(1).to_i

      puts "#{each}: #{tokens} (#{(tokens / 8192.0 * 100).round(1)} %)"
    else
      warn 'Invalid output'
    end
  end
end

desc 'luacheck で src/ を検査'
task :lint do
  sh "#{LUACHECK} src"
end

desc 'PMD CPD でコードの重複を検出'
task :dupe do
  sh "#{PMD} cpd --dir src/ --language lua --minimum-tokens 10"
end
