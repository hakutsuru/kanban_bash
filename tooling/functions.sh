#
# library functions
#

function pipeline_log_stage()
{
    PIPELINE_SECTION=$1
	echo ""
	echo "###############################################"
	echo "###############################################"
	echo "######## "
	echo "########  $PIPELINE_SECTION"
	echo "######## "
	echo "###############################################"
	echo "###############################################"
	echo ""
}

function pipeline_log_action()
{
    action=$1
    echo "########  $action"
}

function pipeline_log_info()
{
    info=$1
	echo ">>>>>>>>  $info"
}
