.POSIX:
.PHONY: init clean distclean build-openssl build publish-local-snapshot \
	publish-local-release publish-remote-snapshot public-remote-release check
GRADLE = ./gradlew

# for JAR build with JNI NDK lib:
JNI_LIB_BUILD_PATH = android-database-sqlcipher/build/intermediates/transforms/stripDebugSymbol/release/0/lib
CLEAN_JAR_BUILD = rm -rf lib *.jar
JNI_LIB_JAR_FILENAME = android-database-sqlcipher-evplus-ext-native-driver.jar

init:
	git submodule update --init

clean:
	$(CLEAN_JAR_BUILD)
	$(GRADLE) clean

distclean:
	$(CLEAN_JAR_BUILD)
	$(GRADLE) distclean

build-openssl:
	$(GRADLE) buildOpenSSL

check:
	$(GRADLE) check

format:
	$(GRADLE) editorconfigFormat

build-debug: check
	$(GRADLE) android-database-sqlcipher:bundleDebugAar \
	-PdebugBuild=true

build-release: check
	$(GRADLE) android-database-sqlcipher:bundleReleaseAar \
	-PdebugBuild=false

# JAR build:
jar: init build-release
	$(CLEAN_JAR_BUILD)
	cp -r $(JNI_LIB_BUILD_PATH) .
	jar cf $(JNI_LIB_JAR_FILENAME) lib

publish-local-snapshot:
	@ $(collect-signing-info) \
	$(GRADLE) \
	-PpublishSnapshot=true \
	-PpublishLocal=true \
	-PsigningKeyId="$$gpgKeyId" \
	-PsigningKeyRingFile="$$gpgKeyRingFile" \
	-PsigningKeyPassword="$$gpgPassword" \
	uploadArchives

publish-local-release:
	@ $(collect-signing-info) \
	$(GRADLE) \
	-PpublishSnapshot=false \
	-PpublishLocal=true \
	-PsigningKeyId="$$gpgKeyId" \
	-PsigningKeyRingFile="$$gpgKeyRingFile" \
	-PsigningKeyPassword="$$gpgPassword" \
	uploadArchives

publish-remote-snapshot:
	@ $(collect-signing-info) \
	$(collect-nexus-info) \
	$(GRADLE) \
	-PpublishSnapshot=true \
	-PpublishLocal=false \
	-PsigningKeyId="$$gpgKeyId" \
	-PsigningKeyRingFile="$$gpgKeyRingFile" \
	-PsigningKeyPassword="$$gpgPassword" \
	-PnexusUsername="$$nexusUsername" \
	-PnexusPassword="$$nexusPassword" \
	uploadArchives

publish-remote-release:
	@ $(collect-signing-info) \
	$(collect-nexus-info) \
	$(GRADLE) \
	-PpublishSnapshot=false \
	-PpublishLocal=false \
	-PdebugBuild=false \
	-PsigningKeyId="$$gpgKeyId" \
	-PsigningKeyRingFile="$$gpgKeyRingFile" \
	-PsigningKeyPassword="$$gpgPassword" \
	-PnexusUsername="$$nexusUsername" \
	-PnexusPassword="$$nexusPassword" \
	uploadArchives

collect-nexus-info := \
	read -p "Enter Nexus username:" nexusUsername; \
	stty -echo; read -p "Enter Nexus password:" nexusPassword; stty echo;

collect-signing-info := \
	read -p "Enter GPG signing key id:" gpgKeyId; \
	read -p "Enter full path to GPG keyring file \
	(possibly ${HOME}/.gnupg/secring.gpg)" gpgKeyRingFile; \
	stty -echo; read -p "Enter GPG password:" gpgPassword; stty echo;
