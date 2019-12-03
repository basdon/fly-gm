ppfile = preprocess.sed
ppfileoutline = preprocess-outline.sed

SOURCES := $(wildcard *.pwn)
OBJECTS := $(patsubst %.pwn, p/%.p, $(SOURCES))

build: $(OBJECTS)

p/%.p: %.pwn $(ppfile) $(ppfileoutline)
	sed -f $(ppfileoutline) $<|sed -f $(ppfile)>$@

clean:
	rm p/*.p
