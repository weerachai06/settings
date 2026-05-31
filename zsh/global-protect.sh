globalprotect() {
  case $1 in
    start)
      echo "Starting GlobalProtect..."
      launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist
      launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist
      echo "Done!"
      ;;
    stop)
      echo "Stopping GlobalProtect..."
      launchctl remove com.paloaltonetworks.gp.pangps
      launchctl remove com.paloaltonetworks.gp.pangpa
      echo "Done!"
      ;;
    *)
      echo "Usage: globalprotect {start|stop}"
      ;;
  esac
}
