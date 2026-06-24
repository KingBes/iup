TARGETS := iup iupcd iupcontrols iupgl iupglcontrols iupim iupimglib ledc iupview iupvled
TARGETS := $(filter-out $(EXCLUDE_TARGETS), $(TARGETS))
OTHERDEPENDENCIES := iupgtk iupmot

.PHONY: do_all $(TARGETS) $(OTHERDEPENDENCIES)
do_all: $(TARGETS)

iup iupgtk iupmot:
	@$(MAKE) --no-print-directory -C ./src/ $@
iupcd:
	@$(MAKE) --no-print-directory -C ./srccd/
iupcontrols:
	@$(MAKE) --no-print-directory -C ./srccontrols/
iupgl:
	@$(MAKE) --no-print-directory -C ./srcgl/
iupglcontrols:
	@$(MAKE) --no-print-directory -C ./srcglcontrols/
iupim:
	@$(MAKE) --no-print-directory -C ./srcim/
iupimglib:
	@$(MAKE) --no-print-directory -C ./srcimglib/
ledc:
	@$(MAKE) --no-print-directory -C ./srcledc/
iupview: iupcontrols iup
	@$(MAKE) --no-print-directory -C ./srcview/
iupvled: iupcontrols iup
	@$(MAKE) --no-print-directory -C ./srcvled/
