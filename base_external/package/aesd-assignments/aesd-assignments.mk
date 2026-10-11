
##############################################################
#
# AESD-ASSIGNMENTS
#
##############################################################

# Published Assignment 4 Part 1 commit. The package patch includes Part 2
# source changes until those changes are reviewed and pushed upstream.
AESD_ASSIGNMENTS_VERSION = 1f9f28513dac1215d2f14a59fd8fdd0ed95698c0
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
AESD_ASSIGNMENTS_SITE = git@github.com:EmbeddedJoKe/aeld-assignment-3-and-later.git
AESD_ASSIGNMENTS_SITE_METHOD = git
AESD_ASSIGNMENTS_GIT_SUBMODULES = YES

define AESD_ASSIGNMENTS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/finder-app all
endef

define AESD_ASSIGNMENTS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/finder-app/writer $(TARGET_DIR)/usr/bin/writer
	$(INSTALL) -D -m 0755 $(@D)/finder-app/finder.sh $(TARGET_DIR)/usr/bin/finder.sh
	$(INSTALL) -D -m 0755 $(@D)/finder-app/finder-test.sh $(TARGET_DIR)/usr/bin/finder-test.sh
	ln -sf finder-test.sh $(TARGET_DIR)/usr/bin/tester.sh
	$(INSTALL) -D -m 0644 $(@D)/conf/username.txt $(TARGET_DIR)/etc/finder-app/conf/username.txt
	$(INSTALL) -D -m 0644 $(@D)/conf/assignment.txt $(TARGET_DIR)/etc/finder-app/conf/assignment.txt
endef

$(eval $(generic-package))
