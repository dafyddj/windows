$(_module_name)_srcs := $(addprefix $(_module_path)/,$(srcs)) $(extra_srcs)
$(_module_name)_targets := $(addprefix $(_module_name)-,$(win_vers))

$(foreach win_ver,$(win_vers), \
  $(eval $(_module_name)_artifact_$(win_ver) := $($(_module_name)_output)/$(artifact_pre)$(win_ver)$(artifact_ext)))
$(_module_name)_artifacts := $(foreach win_ver,$(win_vers),$($(_module_name)_artifact_$(win_ver)))

ifneq ($(_NO_RULES),T)
ifneq ($($(_module_name)_defined),T)
all: $($(_module_name)_targets)

.PHONY: $(_module_name) $($(_module_name)_targets) $(win_vers)
$(_module_name): $($(_module_name)_targets)
$(win_vers): %: $(_module_name)-%
$($(_module_name)_targets): $(_module_name)-%: $($(_module_name)_output)/$(artifact_pre)%$(artifact_ext)

_CLEAN := clean-$(_module_name)
_CLEAN_2 := $(addprefix $(_CLEAN)-,$(win_vers))
.PHONY: clean $(_CLEAN_1) $(_CLEAN_2)
clean: $(_CLEAN)
$(_CLEAN): %: $(addprefix %-,$(win_vers))
$(_CLEAN_2): clean-$(_module_name)-%:
	$(info Cleaning $($(_module_name)_output)/$*$(artifact_ext))

$($(_module_name)_artifacts): _path := $(_module_path)

.SECONDEXPANSION:
$($(_module_name)_output)/$(artifact_pre)%$(vdiext): $($(_module_name)_srcs) $$($($(_module_name)_depends_on))
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $* poweroff 2>/dev/null || true
	@$(VBOXMANAGE) unregistervm $* --delete 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$* $(_path)

.SECONDEXPANSION:
$($(_module_name)_output)/$(artifact_pre)%$(snapext): $($(_module_name)_srcs) $$($($(_module_name)_depends_on))
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $* poweroff 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$* $(_path)
	@touch $@

.SECONDEXPANSION:
$($(_module_name)_output)/$(artifact_pre)%$(boxext): $($(_module_name)_srcs) $$($($(_module_name)_depends_on))
	$(info Making $@)
	@$(VBOXMANAGE) controlvm $* poweroff 2>/dev/null || true
	@$(PACKER) build $(PFLAGS) -only \*.$* $(_path)

%.cat.pkr.hcl: %.build %.provision
	$(info Making $@)
	cat $^ > $@
	echo } >> $@

$(_module_name)_defined := T
endif
endif