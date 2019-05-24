ppfile = preprocess.sed
ppfileoutline = preprocess-outline.sed

# manually added natives&sharedsymbols because they might not be
#   present in this dir when building the first time
SOURCES := $(wildcard *.pwn) natives.pwn sharedsymbols.pwn
OBJECTS := $(patsubst %.pwn, p/%.p, $(SOURCES))

build: $(OBJECTS)

natives.pwn: ../../plugin/basdonfly.pwn
	cp ..\..\plugin\basdonfly.pwn natives.pwn

sharedsymbols.pwn: ../../plugin/sharedsymbols.h
	cp ..\..\plugin\sharedsymbols.h sharedsymbols.pwn

p/%.p: %.pwn $(ppfile) $(ppfileoutline)
	bash -c "sed -f $(ppfileoutline) $<|sed -f $(ppfile)>$@"

clean:
	rm p/*.p
