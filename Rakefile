# TODO: add support for Resources, C++, Objective-C++ and Sub-Frameworks

FRAMEWORK_NAME = "Min"
FRAMEWORK_VERSION = "A"
INSTALL_DIR = "/Library/Frameworks"

OBJC_FLAGS = "-fobjc-gc" # so i can load the framework with macruby
CC_FLAGS = "" # -fobjc-gc not allowed for C-files...
LD_FLAGS = ""

COPY_HEADERS = false

# edit below, only if you know what you are doing :)

FRAMEWORK_DIR = "#{FRAMEWORK_NAME}.framework"
FRAMEWORK_VERSIONS_DIR = "#{FRAMEWORK_DIR}/Versions"
FRAMEWORK_CURRENT = "#{FRAMEWORK_VERSIONS_DIR}/Current"
FRAMEWORK_VERSION_DIR = "#{FRAMEWORK_DIR}/Versions/#{FRAMEWORK_VERSION}"

FRAMEWORK_VERSION_DYNLIB = "#{FRAMEWORK_VERSION_DIR}/#{FRAMEWORK_NAME}"
FRAMEWORK_DYNLIB = "#{FRAMEWORK_DIR}/#{FRAMEWORK_NAME}"

@@SRC = []
@@OBJ = []
@@HEADERS = []
@@INCLUDE_DIRS = '' 

task :default => ['framework']

task :create_framework_targets do
    @@SRC = FileList["{,*/**/}*.c", "{,*/**/}*.m"]
    @@OBJ = @@SRC.map { |f| 'build/' + File.basename(f) + '.o' }
    @@HEADERS = FileList["{,*/**/}*.h"].reject do |h|
        h =~ /^#{FRAMEWORK_NAME}\.framework/
    end
    @@INCLUDE_DIRS = @@HEADERS.map {|h| File.dirname(h) }.uniq.map {|d| '-I'+d }.join(' ')

    directory "build"
    # create Framework and Version directory
    directory FRAMEWORK_DIR
    directory FRAMEWORK_VERSION_DIR

    file FRAMEWORK_VERSION_DYNLIB => (@@OBJ + [FRAMEWORK_DIR, FRAMEWORK_VERSION_DIR]) do
        sh "gcc -dynamiclib -framework Foundation #{LD_FLAGS} -o #{FRAMEWORK_VERSION_DYNLIB} #{@@OBJ}"
    end

    file FRAMEWORK_CURRENT => [FRAMEWORK_VERSION_DIR] do
        sh "cd #{FRAMEWORK_VERSIONS_DIR} && ln -s #{FRAMEWORK_VERSION} Current"
    end

    file FRAMEWORK_DYNLIB => [FRAMEWORK_VERSION_DYNLIB] do
        sh "cd #{FRAMEWORK_DIR} && ln -s Versions/Current/#{FRAMEWORK_NAME} #{FRAMEWORK_NAME}"
    end

    if COPY_HEADERS
        FRAMEWORK_HEADERS = "#{FRAMEWORK_VERSION_DIR}/Headers"
        FRAMEWORK_HEADERS_LINK = "#{FRAMEWORK_DIR}/Headers"

        directory FRAMEWORK_HEADERS
        file FRAMEWORK_HEADERS_LINK => [FRAMEWORK_HEADERS] do
            sh "cd #{FRAMEWORK_DIR} && ln -s Versions/Current/Headers Headers"
        end

        task :copy_headers => [FRAMEWORK_HEADERS] do 
            @@HEADERS.each do |h|
                if not File.exists? "#{FRAMEWORK_HEADERS}/#{h}"
                    sh "cp #{h} #{FRAMEWORK_HEADERS}"
                end
            end
        end
    end

    # create file dependencies...
    @@SRC.zip(@@OBJ) do |src,obj|
        cmd = "gcc #{@@INCLUDE_DIRS} -M -MM #{src}"
        dep = ["build"] + `#{cmd}`.delete("\\\\\n").sub(/.*:\s*/,'').split(/\s+/)
        if File.extname(src) == '.c' 
            file obj => dep do
                sh "gcc #{@@INCLUDE_DIRS} #{CC_FLAGS} -c -o #{obj} #{src}"
            end
        else
            file obj => dep do
                sh "gcc #{@@INCLUDE_DIRS} #{OBJC_FLAGS} -c -o #{obj} #{src}"
            end
        end
    end
end

FRAMEWORK_DEPENDENCIES = [FRAMEWORK_VERSION_DYNLIB, FRAMEWORK_CURRENT, FRAMEWORK_DYNLIB]
if COPY_HEADERS
    FRAMEWORK_DEPENDENCIES << :copy_headers << FRAMEWORK_HEADERS_LINK
end

task 'framework' => [:create_framework_targets] + FRAMEWORK_DEPENDENCIES do
end

task 'install' => 'framework' do
    sh "cp -r #{FRAMEWORK_DIR} #{INSTALL_DIR}"
end

task :clean do
    sh "rm -fR build"
end

task :distclean => [:clean] do
    sh "rm -fR #{FRAMEWORK_DIR}"
end

