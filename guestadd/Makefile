sp := $(subst ,, )
_walk = $(if $1,$(wildcard /$(subst $(sp),/,$1)/$2) $(call _walk,$(wordlist 2,$(words $1),x $1),$2))
_find = $(firstword $(call _walk,$(strip $(subst /, ,$1)),$2))
_ROOT := $(patsubst %/root.mk,%,$(call _find,$(CURDIR),root.mk))

include $(_ROOT)/root.mk

$(call depends_on,install)

include $(_ROOT)/pre.mk

srcs := main.cat.pkr.hcl
artifact_pre := .
artifact_ext := $(snapext)

$(_module_name)_depends_on := install_artifact_$$*

include $(_ROOT)/post.mk
