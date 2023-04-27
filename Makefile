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
SLEIGH_ARGS := -x -u -l -t -e -f

LANGDIR := data/languages
SLASPEC := $(wildcard $(LANGDIR)/*.slaspec)
SLA := $(SLASPEC:.slaspec=.sla)
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

$(LANGDIR)/%.sla: $(LANGDIR)/%.slaspec $(LANGDIR)/*.sinc
	$(SLEIGH) $(SLEIGH_ARGS) $< $@

$(IDX): $(LANGDIR)/*.sinc
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
