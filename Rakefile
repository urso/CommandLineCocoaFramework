# TODO: add support for Resources, C++, Objective-C++ and Sub-Frameworks

CC = "clang"

FRAMEWORK_NAME = "Min"
FRAMEWORK_VERSION = "A"
INSTALL_DIR = "/Library/Frameworks"
USE_FRAMEWORKS = ['Cocoa', 'Foundation']

OBJC_FLAGS = "-fobjc-gc" # so i can load the framework with macruby
CC_FLAGS = "" # -fobjc-gc not allowed for C-files...
LD_FLAGS = ""

COPY_HEADERS = true
COMPILE_PARALLEL = true

# edit below, only if you know what you are doing :)

LD_FRAMEWORKS = USE_FRAMEWORKS.map{|f| '-framework '+f}.join(' ')

FRAMEWORK_DIR = "#{FRAMEWORK_NAME}.framework"
FRAMEWORK_VERSIONS_DIR = "#{FRAMEWORK_DIR}/Versions"
FRAMEWORK_CURRENT = "#{FRAMEWORK_VERSIONS_DIR}/Current"
FRAMEWORK_VERSION_DIR = "#{FRAMEWORK_DIR}/Versions/#{FRAMEWORK_VERSION}"

FRAMEWORK_VERSION_DYNLIB = "#{FRAMEWORK_VERSION_DIR}/#{FRAMEWORK_NAME}"
FRAMEWORK_DYNLIB = "#{FRAMEWORK_DIR}/#{FRAMEWORK_NAME}"

task :default => ['framework']

task :create_framework_targets do
    SRC = FileList["**{,/*/**/}*.c", "**{,/*/**/}*.m"]
    DEPS = SRC.map { |f| 'build/' + File.basename(f) + '.d' }
    OBJ = SRC.map { |f| 'build/' + File.basename(f) + '.o' }
    HEADERS = FileList["**{,/*/**/}*.h"].reject do |h|
        h =~ /^#{FRAMEWORK_NAME}\.framework/
    end
    INCLUDE_DIRS = HEADERS.map {|h| File.dirname(h) }.uniq.map {|d| '-I'+d }.join(' ')

    directory "build"
    # create Framework and Version directory
    directory FRAMEWORK_DIR
    directory FRAMEWORK_VERSION_DIR

    if COMPILE_PARALLEL
        multitask :compile => OBJ
    else
        task :compile => OBJ
    end

    file FRAMEWORK_VERSION_DYNLIB => [:compile, FRAMEWORK_DIR, FRAMEWORK_VERSION_DIR] do
        sh "gcc -dynamiclib #{LD_FRAMEWORKS} #{LD_FLAGS} -o #{FRAMEWORK_VERSION_DYNLIB} #{OBJ}"
    end

    file FRAMEWORK_CURRENT => [FRAMEWORK_VERSION_DIR] do
        sh "cd #{FRAMEWORK_VERSIONS_DIR} && ln -s #{FRAMEWORK_VERSION} Current"
    end

    file FRAMEWORK_DYNLIB => [FRAMEWORK_VERSION_DYNLIB] do
        sh "cd #{FRAMEWORK_DIR} && ln -s Versions/Current/#{FRAMEWORK_NAME} #{FRAMEWORK_NAME}"
    end

    if COPY_HEADERS
        FRAMEWORK_HEADERS_DIR = "#{FRAMEWORK_VERSION_DIR}/Headers"

        directory FRAMEWORK_HEADERS_DIR
        file FRAMEWORK_HEADERS_LINK => [FRAMEWORK_HEADERS_DIR] do
            sh "cd #{FRAMEWORK_DIR} && ln -s Versions/Current/Headers Headers"
        end

        FRAMEWORK_HEADERS = HEADERS.map {|h| "#{FRAMEWORK_HEADERS_DIR}/#{File.basename(h)}"}

        FRAMEWORK_HEADERS.zip(HEADERS) do |fh, h|
            file fh => [FRAMEWORK_HEADERS_DIR, h] do
                sh "cp #{h} #{fh}"
            end
        end

        multitask :copy_headers => FRAMEWORK_HEADERS
    end

    # create file dependencies...
    SRC.zip(DEPS, OBJ) do |src,depfile,obj|
        deps = ""
        if File.exists?(depfile)
            deps = File.read(depfile).split(/\s+/)
        else
            deps = [src]
        end

        file depfile => ['build'] + deps do
            File.open(depfile, "w") do |f|
                cmd = "gcc #{INCLUDE_DIRS} -M -MM #{src}"
                depstr = `#{cmd}`.delete("\\\\\n").sub(/.*:\s*/,'')
                f.write(depstr)
            end
        end

        if File.extname(src) == '.c' 
            file obj => depfile do
                sh "#{CC} #{INCLUDE_DIRS} #{CC_FLAGS} -c -o #{obj} #{src}"
            end
        else
            file obj => depfile do
                sh "#{CC} #{INCLUDE_DIRS} #{OBJC_FLAGS} -c -o #{obj} #{src}"
            end
        end
    end
end

FRAMEWORK_DEPENDENCIES = [FRAMEWORK_VERSION_DYNLIB, FRAMEWORK_CURRENT, FRAMEWORK_DYNLIB]
if COPY_HEADERS
    FRAMEWORK_HEADERS_LINK = "#{FRAMEWORK_DIR}/Headers"
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

