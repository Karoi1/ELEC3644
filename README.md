# ELEC3644
A demo ios app for ELEC3644  
This is a recipe app  
  
Class user  
    Int id  
    String name
    String password
    [Int] favs  
    [Int] hist  
    [Int] comment  
  
Class Recipe  
    Int id  
    String name  
    [String] recipe  
    [String] tag  
    String description  
  
Struct userpage : View  
  private var correctName  
  private var correctPW  

  var body: some view
    subview--login button, username field, pw field  
        check the name and pw  
    main view--username, photo, hist, favs, comments  
    subview--hist button, show hist  
    subview--favs button, show favs  
    subview--comment button, show comments
