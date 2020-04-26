#!/bin/sh

#
# *** How to use ***
#
# 下記のinstallと同等
# $ sudo install.sh
#
# OSをアップデートせずにサーバープログラムだけをインストール
# $ sudo install.sh install
#
# OSアップデートとタイムゾーンのセットをした上でインストール
# $ sudo install.sh fullinstall
#
# バージョン1.1を指定してインストール
# $ sudo install.sh -r 1.1
#
# サーバープログラムのみを最新にアップデート
# $ sudo install.sh update
#
# サーバープログラムをバージョン1.2へアップデート
# $ sudo install.sh -r 1.2 update
#
# OSとサーバープログラムを最新にアップデート
# $ sudo install.sh fullupdate
#

if [ $(id -ru) -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

CURL=/usr/bin/curl
TAR=/bin/tar
CAT=/bin/cat
CURL=/usr/bin/curl
SYSTEMCTL=/bin/systemctl
CHMOD=/bin/chmod
SED=/bin/sed
A2ENMOD=/usr/sbin/a2enmod
A2ENCONF=/usr/sbin/a2enconf
RSYNC=/usr/bin/rsync
RM=/bin/rm
CP=/bin/cp
JQ=/usr/bin/jq
MKDIR=/bin/mkdir
MKTEMP=/bin/mktemp
SLEEP=/bin/sleep
RASPICONFIG=/usr/bin/raspi-config
TIMEDATECTL=/usr/bin/timedatectl

WORKDIR=/tmp
DOCUMENTROOT=/var/www/localhost/htdocs
CGIDIR=${DOCUMENTROOT}/ctrl

CSPIDIR=/var/lib/crystal-signal
SCRIPTDIR=${CSPIDIR}/scripts
SOUNDSDIR=${CSPIDIR}/sounds
SCRIPTCONFFILE=${CSPIDIR}/ScriptSettings.json
GENERALCONFFILE=${CSPIDIR}/Settings.json

JQUERY=jquery-3.1.1.min.js

SERVERVER=1.2

while getopts :r: OPT
do
    case $OPT in
        r)
            SERVERVER=$OPTARG
            ;;
        \?)
            ;;
    esac
done

shift $(($OPTIND - 1))

function install_apache
{
    mkdir -p /run/apache2
    $SED -i -e '/.*#AddHandler cgi-script .cgi$/i \\tAddHandler cgi-script .py' /etc/apache2/httpd.conf
    $SED -i -e '/.*#LoadModule cgid_module modules\/mod_cgid.so$/i \\tLoadModule cgid_module modules/mod_cgid.so' /etc/apache2/httpd.conf
    $SED -i -e '/.*#LoadModule cgi_module modules\/mod_cgi.so$/i \\tLoadModule cgi_module modules/mod_cgi.so' /etc/apache2/httpd.conf
    echo ServerName $HOSTNAME > /etc/apache2/conf.d/fqdn.conf

    $CAT > /etc/apache2/conf.d/crystal-signal.conf <<EOF
<Directory /var/www/localhost/htdocs/ctrl>
     Options +Indexes +ExecCGI
     DirectoryIndex controller.py
</Directory>
EOF
}

function install_crystalsignal
{
    $CURL -sSL -o ${WORKDIR}/crystal-signal.tar.gz "https://github.com/infiniteloop-inc/crystal-signal/archive/${SERVERVER}.tar.gz"

    $TAR xf ${WORKDIR}/crystal-signal.tar.gz -C $WORKDIR

    $CHMOD +x ${WORKDIR}/crystal-signal-${SERVERVER}/bin/*
    $RSYNC -avz ${WORKDIR}/crystal-signal-${SERVERVER}/bin/ /usr/local/bin/

    # install button & alert scripts
    if [ ! -d "${CSPIDIR}" ]; then
        $MKDIR ${CSPIDIR}
    fi

    if [ ! -d "${SCRIPTDIR}" ]; then
        $MKDIR ${SCRIPTDIR}
    fi

    if [ ! -d "${SOUNDSDIR}" ]; then
        $MKDIR ${SOUNDSDIR}
    fi

    # install version file
    $CP ${WORKDIR}/crystal-signal-${SERVERVER}/VERSION ${CSPIDIR}

    # install sample scripts
    $CHMOD +x ${WORKDIR}/crystal-signal-${SERVERVER}/scripts/*
    $RSYNC -avz ${WORKDIR}/crystal-signal-${SERVERVER}/scripts/ $SCRIPTDIR
    $SED -i -e '/^#!\/bin\/bash$/i #!/bin/sh' $SCRIPTDIR/Ack.sh
    $SED -i -e '/^#!\/bin\/bash$/i #!/bin/sh' $SCRIPTDIR/AckNewestOnly.sh
    $SED -i -e '/^#!\/bin\/bash$/i #!/bin/sh' $SCRIPTDIR/AlarmSound.sh

    # install sample sound files
    $RSYNC -avz ${WORKDIR}/crystal-signal-${SERVERVER}/sounds/ $SOUNDSDIR

    # install default config file
    if [ ! -f $GENERALCONFFILE ]; then
        $CAT > $GENERALCONFFILE <<EOF
{"brightness": 43}
EOF
    fi

    if [ ! -f $SCRIPTCONFFILE ]; then
        $CAT > $SCRIPTCONFFILE <<EOF
{"dropdown4": "---", "dropdown5": "---", "dropdown1": "---", "dropdown2": "Ack.sh", "dropdown3": "---"}
EOF
    fi

    # install HTML
    $RSYNC -avz ${WORKDIR}/crystal-signal-${SERVERVER}/html/ ${DOCUMENTROOT}/
    $CHMOD +x ${CGIDIR}/*.py

    # delete working directory
    $RM -rf ${WORKDIR}/crystal-signal-${SERVERVER}

    # install jQuery
    if [ ! -d "${DOCUMENTROOT}/js" ]; then
        $MKDIR ${DOCUMENTROOT}/js
    fi

    if [ ! -f "${DOCUMENTROOT}/js/${JQUERY}" ]; then
        $CURL -sSL -o ${DOCUMENTROOT}/js/${JQUERY} "https://code.jquery.com/${JQUERY}"
    fi

    # install bootstrap
    if [ ! -d "${DOCUMENTROOT}/css" ]; then
        $MKDIR ${DOCUMENTROOT}/css
    fi

    if [ ! -f "${DOCUMENTROOT}/css/bootstrap-3.3.7.min.css" ]; then
        $CURL -sSL -o ${DOCUMENTROOT}/css/bootstrap-3.3.7.min.css "https://raw.githubusercontent.com/infiniteloop-inc/bootstrap/v3-dev/dist/css/bootstrap.min.css"
    fi
    if [ ! -f "${DOCUMENTROOT}/js/bootstrap-3.3.7.min.js" ]; then
        $CURL -sSL -o ${DOCUMENTROOT}/js/bootstrap-3.3.7.min.js "https://raw.githubusercontent.com/infiniteloop-inc/bootstrap/v3-dev/dist/js/bootstrap.min.js"
    fi

    # install bootstrap-slider
    if [ ! -f "${DOCUMENTROOT}/css/bootstrap-slider-9.5.1.min.css" ]; then
        $CURL -sSL -o ${DOCUMENTROOT}/css/bootstrap-slider-9.5.1.min.css "https://raw.githubusercontent.com/infiniteloop-inc/bootstrap-slider/master/dist/css/bootstrap-slider.min.css"
    fi
    if [ ! -f "${DOCUMENTROOT}/js/bootstrap-slider-9.5.1.min.js" ]; then
        $CURL -sSL -o ${DOCUMENTROOT}/js/bootstrap-slider-9.5.1.min.js "https://raw.githubusercontent.com/infiniteloop-inc/bootstrap-slider/master/dist/bootstrap-slider.min.js"
    fi
}

case "$1" in
    "update")
        install_crystalsignal
        ;;
    "fullupdate")
        os_update
        install_crystalsignal
        ;;
    "install")
        install_apache
        install_crystalsignal
        ;;
    "fullinstall")
        os_update
        install_apache
        install_crystalsignal
        ;;
    *)
        install_apache
        install_crystalsignal
        ;;
esac

echo "FINISHED"
