let project = new Project('khame');

//Android settings
project.targetOptions.android.screenOrientation = "sensor";
project.targetOptions.android.package = "com.jefvel.coolgame";

project.addAssets("Assets/**");

project.addShaders('Shaders');
project.addSources('Sources');

resolve(project);
