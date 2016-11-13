let project = new Project('Plant Trees 4 Santa');

//Android settings
project.targetOptions.android.screenOrientation = 'sensor';
project.targetOptions.android.package = 'com.jefvel.coolgame';

project.targetOptions.html5.indexTemplate = 'Templates/index.html';
project.targetOptions.html5.debugIndexTemplate = 'Templates/index.html';

project.addAssets('Assets/**');

project.addLibrary('kek');

project.addShaders('Shaders');
project.addSources('Sources');

resolve(project);
