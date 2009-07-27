# autoconf-archive/cfg.mk

# settings required by the maintainer-makefile module

gnu_rel_host	:= savannah.nongnu.org
old_NEWS_hash	:= 5ad7b87198d89e04d76b99221591c076
gpg_key_ID	:= 99089D72
url_dir_list	:= http://download.savannah.nongnu.org/releases/autoconf-archive
today		:= $(date "+%Y-%m-%d")
TAR_OPTIONS	+= --mtime=$(today)

# maintainer targets

M4DIR		:= $(srcdir)/m4
HTMLDIR		:= $(srcdir)/html
STAGEDIR	:= $(srcdir)/stage

M4_FILES	:= $(wildcard $(M4DIR)/*.m4)
MACROS		:= $(patsubst $(M4DIR)/%.m4,%, $(M4_FILES))
HTML_FILES	:= $(patsubst %,$(HTMLDIR)/%.html,$(MACROS))
TEXI_FILES	:= $(patsubst %,$(STAGEDIR)/%.texi,$(MACROS))

.PHONY: generate
ALL_RECURSIVE_TARGETS += generate
generate: $(HTML_FILES) $(TEXI_FILES) autoconf-archive.info

$(STAGEDIR)/manifest:
	@$(MKDIR_P) $(STAGEDIR)
	@rm -f "$@"
	@for n in $(basename $(notdir $(M4_FILES))); do echo "$$n" >>"$@"; done

$(STAGEDIR)/%.html : $(M4DIR)/%.m4 $(STAGEDIR)/manifest $(srcdir)/macro.py $(srcdir)/macro2html.py
	@echo generating $@
	@$(srcdir)/macro2html.py "$<" "$@"

$(STAGEDIR)/%.texi : $(M4DIR)/%.m4 $(STAGEDIR)/manifest $(srcdir)/macro.py $(srcdir)/macro2texi.py
	@echo generating $@
	@$(srcdir)/macro2texi.py "$<" "$@"

$(HTMLDIR)/%.html : $(STAGEDIR)/%.html
	@echo pretty-printing $@
	@tidy -quiet -ascii --indent yes --indent-spaces 1 --tidy-mark no -wrap 80 --hide-comments yes "$<" >"$@"

$(STAGEDIR)/all-macros.texi:	$(TEXI_FILES)
	@$(MKDIR_P) $(STAGEDIR)
	@rm -f "$@"
	@for n in $(TEXI_FILES); do echo "@include $$n" >>"$@"; done

autoconf-archive.info: autoconf-archive.texi $(STAGEDIR)/all-macros.texi $(STAGEDIR)/version.texi
	makeinfo $<

$(STAGEDIR)/version.texi:
	echo @set VERSION $(VERSION) >"$@"

taint-distcheck:

my-distcheck:
