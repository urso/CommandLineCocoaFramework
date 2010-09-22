# TODO: add support for Resources, C++, Objective-C++ and Sub-Frameworks

INSTALL_DIR = "/Library/Frameworks"
FRAMEWORK_NAME = "Min"
FRAMEWORK_VERSION = "A"

CC_FLAGS = "-fobjc-gc" # so i can load the framework with macruby
LD_FLAGS = ""

COPY_HEADERS = true

# edit below, only if you know what you are doing :)

SRC = FileList['**/*.c', '**/*.m']
OBJ = SRC.ext('o')
HEADERS = FileList['**/*.h'].reject do |h|
    h =~ /^#{FRAMEWORK_NAME}/
end

# create file dependencies...
SRC.each do |f|
    obj = f.ext('.o')
    `gcc -M -MM #{f}` =~ /^.*:\s*(.*)/
    file obj => $1.split(/\s+/)
end

FRAMEWORK_DIR = "#{FRAMEWORK_NAME}.framework"
FRAMEWORK_VERSIONS_DIR = "#{FRAMEWORK_DIR}/Versions"
FRAMEWORK_CURRENT = "#{FRAMEWORK_VERSIONS_DIR}/Current"
FRAMEWORK_VERSION_DIR = "#{FRAMEWORK_DIR}/Versions/#{FRAMEWORK_VERSION}"

FRAMEWORK_VERSION_DYNLIB = "#{FRAMEWORK_VERSION_DIR}/#{FRAMEWORK_NAME}"
FRAMEWORK_DYNLIB = "#{FRAMEWORK_DIR}/#{FRAMEWORK_NAME}"

task :default => ['framework']

# TODO add rules for building C++ and Objective-C++
rule '.o' => '.c' do |t|
    sh "gcc #{CC_FLAGS} -c -o #{t.name} #{t.source}"
end

rule '.o' => '.m' do |t|
    sh "gcc #{CC_FLAGS} -c -o #{t.name} #{t.source}"
end

# create Framework and Version directory
directory FRAMEWORK_DIR
directory FRAMEWORK_VERSION_DIR

FRAMEWORK_DEPENDENCIES = [FRAMEWORK_VERSION_DYNLIB, FRAMEWORK_CURRENT, FRAMEWORK_DYNLIB]

if COPY_HEADERS
    FRAMEWORK_HEADERS = "#{FRAMEWORK_VERSION_DIR}/Headers"
    FRAMEWORK_HEADERS_LINK = "#{FRAMEWORK_DIR}/Headers"

    directory FRAMEWORK_HEADERS
    file FRAMEWORK_HEADERS_LINK => [FRAMEWORK_HEADERS] do
        sh "cd #{FRAMEWORK_DIR} && ln -s Versions/Current/Headers Headers"
    end

    task :copy_headers => [FRAMEWORK_HEADERS] do 
        HEADERS.each do |h|
            if not File.exists? "#{FRAMEWORK_HEADERS}/#{h}"
                sh "cp #{h} #{FRAMEWORK_HEADERS}"
            end
        end
    end

    FRAMEWORK_DEPENDENCIES << :copy_headers << FRAMEWORK_HEADERS_LINK
end

file FRAMEWORK_VERSION_DYNLIB => [OBJ, FRAMEWORK_DIR, FRAMEWORK_VERSION_DIR] do
    sh "gcc -dynamiclib -framework Foundation #{LD_FLAGS} -o #{FRAMEWORK_VERSION_DYNLIB} #{OBJ}"
end

file FRAMEWORK_CURRENT => [FRAMEWORK_VERSION_DIR] do
    sh "cd #{FRAMEWORK_VERSIONS_DIR} && ln -s #{FRAMEWORK_VERSION} Current"
end

file FRAMEWORK_DYNLIB => [FRAMEWORK_VERSION_DYNLIB] do
    sh "cd #{FRAMEWORK_DIR} && ln -s Versions/Current/#{FRAMEWORK_NAME} #{FRAMEWORK_NAME}"
end

task 'framework' => FRAMEWORK_DEPENDENCIES do
end

task :clean do
    sh "rm -fR #{FRAMEWORK_DIR}"
    sh "rm -f #{OBJ}"
end

task 'install' => 'framework' do
    sh "cp -r #{FRAMEWORK_DIR} #{INSTALL_DIR}"
end
