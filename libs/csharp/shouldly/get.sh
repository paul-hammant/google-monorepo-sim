curl -sSL -o Shouldly.4.3.0.nupkg \
     https://api.nuget.org/v3-flatcontainer/shouldly/4.3.0/shouldly.4.3.0.nupkg \
 && unzip -p Shouldly.4.3.0.nupkg "lib/net9.0/Shouldly.dll" > Shouldly.dll \
 && rm Shouldly.4.3.0.nupkg
