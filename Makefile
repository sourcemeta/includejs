# Programs
CMAKE = cmake
CTEST = ctest

# Options
PRESET = Debug
SHARED = OFF

all: configure compile test

configure: .always
	$(CMAKE) -S . -B ./build \
		-DCMAKE_BUILD_TYPE:STRING=$(PRESET) \
		-DCMAKE_COMPILE_WARNING_AS_ERROR:BOOL=ON \
		-DINCLUDEJS_ENGINE:BOOL=ON \
		-DINCLUDEJS_TESTS:BOOL=ON \
		-DINCLUDEJS_DOCS:BOOL=ON \
		-DBUILD_SHARED_LIBS:BOOL=$(SHARED)

compile: .always
	$(CMAKE) --build ./build --config $(PRESET) --target clang_format
	$(CMAKE) --build ./build --config $(PRESET) --parallel 4
	$(CMAKE) --install ./build --prefix ./build/dist --config $(PRESET) --verbose \
		--component sourcemeta_includejs
	$(CMAKE) --install ./build --prefix ./build/dist --config $(PRESET) --verbose \
		--component sourcemeta_includejs_dev

lint: .always
	$(CMAKE) --build ./build --config $(PRESET) --target clang_tidy

test: .always
	$(CMAKE) -E env UBSAN_OPTIONS=print_stacktrace=1 \
		$(CTEST) --test-dir ./build --build-config $(PRESET) \
			--output-on-failure --progress --parallel

doxygen: .always
	$(CMAKE) --build ./build --config $(PRESET) --target doxygen

clean: .always
	$(CMAKE) -E rm -R -f build

# TODO: For testing purposes
webkit: .always
	$(CMAKE) -E rm -R -f build
	$(CMAKE) -E make_directory build
	cd build && $(CMAKE) ../vendor/webkit -G Ninja \
		-DPORT="JSCOnly" \
		-DENABLE_TOOLS:BOOL=OFF \
		-DDEVELOPER_MODE:BOOL=OFF \
		-DENABLE_FTL_JIT:BOOL=ON \
		-DENABLE_STATIC_JSC:BOOL=ON \
		-DUSE_SYSTEM_MALLOC:BOOL=ON \
		-DUSE_APPLE_ICU:BOOL=ON \
		"-DWEBKIT_LIBRARIES_DIR:STRING=/D/a/includejs/includejs/build/WebKitLibraries" \
		-DCMAKE_BUILD_TYPE:STRING=$(PRESET)
	$(CMAKE) --build ./build --config $(PRESET) --parallel 4

# For NMake, which doesn't support .PHONY
.always:
