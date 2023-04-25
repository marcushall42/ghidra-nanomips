# Assume we are in Ghidra/Processors/subdir
GHIDRA_DIR ?= $(shell readlink -f $(CURDIR)/../../..)
SLEIGH ?= $(GHIDRA_DIR)/support/sleigh
PERL ?= perl

# -x                turns on parser debugging (SleighCompile)
# -u                print warnings for unnecessary pcode instructions (SleighCompile)
# -l                report pattern conflicts (SleighCompile)
# -n                print warnings for all NOP constructors (SleighCompile)
# -t                print warnings for dead temporaries (SleighCompile)
# -e                enforce use of 'local' keyword for temporaries (SleighCompile)
# -f                print warnings for unused token fields (SleighCompile)
SLEIGH_ARGS := -x -u -l -n -t -e -f

LANGDIR := data/languages

# Must start with slaspec.
SLA_SRCS := $(LANGDIR)/nanomipsLE.slaspec $(wildcard $(LANGDIR)/nanomips*.sinc)
SLA := $(LANGDIR)/nanomipsLE.sla

MANDIR := data/manuals
IDX := $(MANDIR)/nanomips.idx

# Targets

.PHONY: all
all: check-ghidra $(SLA) $(IDX)

.PHONY: check-ghidra
check-ghidra:
	@if [ ! -d $(GHIDRA_DIR)/Ghidra ]; then \
		echo "Your Ghidra installation directory could not be determined." >&2; \
		echo "Please re-run make with GHIDRA_DIR set to the root of your Ghidra installation." >&2; \
		exit 1; \
	fi

$(SLA): $(SLA_SRCS)
	$(SLEIGH) $(SLEIGH_ARGS) $< $@

$(IDX): $(SLA_SRCS)
	mkdir -p $(MANDIR)
	$(PERL) mkindex.pl $^ > $@

release.zip: clean all
	mkdir -p release/NanoMIPS/$(LANGDIR)
	cp -r $(LANGDIR)/nanomips* release/NanoMIPS/$(LANGDIR)
	mkdir -p release/NanoMIPS/$(MANDIR)
	cp -r $(MANDIR)/*.idx release/NanoMIPS/$(MANDIR)
	cp Module.manifest release/NanoMIPS
	cd release && zip -r ../$@ .

.PHONY: clean
clean:
	rm -rf $(SLA) $(IDX) release release.zip
