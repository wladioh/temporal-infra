#https://github.com/kubernauts/jmeter-kubernetes
#https://github.com/GoogleCloudPlatform/distributed-load-testing-using-kubernetes
#https://github.com/tsenart/vegeta/issues/336
apt-get -y update && apt-get install -y jmeter
curl search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar -o /usr/share/jmeter/lib/cmdrunner-2.2.jar -L
curl https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.7/jmeter-plugins-manager-1.7.jar -o /usr/share/jmeter/lib/ext/jmeter-plugins-manager.jar
curl https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.35/slf4j-api-1.7.35.jar -o /usr/share/jmeter/lib/slf4j-api-1.7.35.jar -L
java -cp /usr/share/jmeter/lib/ext/jmeter-plugins-manager.jar org.jmeterplugins.repository.PluginManagerCMDInstaller
cd /usr/share/jmeter/bin
sudo curl https://raw.githubusercontent.com/apache/jmeter/master/bin/create-rmi-keystore.sh -o create-rmi-keystore.sh -L
sh PluginsManagerCMD.sh install jpgc-graphs-basic,jpgc-graphs-additional,jpgc-autostop,jpgc-casutg,jpgc-csl,jpgc-dummy,jpgc-ffw,jpgc-filterresults,jpgc-functions,jpgc-json,jpgc-mergeresults,jpgc-prmctl,jpgc-sense,jpgc-tst,jpgc-wsc 