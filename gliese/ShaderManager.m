//
//  ShaderManager.m
//  jecTile
//
//  Created by Joel Pryde on 11/29/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import "ShaderManager.h"
#import "MainGLView.h"
#import "ViewController.h"
#import "GLShaderFuncs.h"
#import "Shader.h"

@implementation ShaderManager

@synthesize shaders = _shaders;

@synthesize textureProgram = _textureProgram;
@synthesize solidColorProgram = _solidColorProgram;
@synthesize currentProgram = _currentProgram;
@synthesize mappingProgram = _mappingProgram;

@synthesize currentShader = _currentShader;
@synthesize editShaderText = _editShaderText;
@synthesize editSuccess = _editSuccess;
@synthesize templateSource = _templateSource;

static ShaderManager* sharedInstance = nil;

+ (ShaderManager*)Instance
{
    return sharedInstance;
}

-(id)init
{
    [super init];
    _shaders = [[NSMutableDictionary alloc] init];
    [self loadSystemShaders];
    [self loadUserShaders];
    [self loadFileShaders];
    
    // save any new loaded file shaders
    [self saveUserShaders];
    
    // load base shader string
    NSString *fsShaderPathname = [[NSBundle mainBundle] pathForResource:@"Template" ofType:@"fsh"];
    _templateSource = [[NSString alloc] initWithContentsOfFile:fsShaderPathname encoding:NSUTF8StringEncoding error:nil];

    _currentShader = nil;
    sharedInstance = self;
    _editSuccess = true;
    return self;
}

-(void)dealloc
{
    if (_textureProgram) 
    {
        glDeleteProgram(_textureProgram);
        _textureProgram = 0;
    }
    if (_solidColorProgram) 
    {
        glDeleteProgram(_solidColorProgram);
        _solidColorProgram = 0;
    }
    if (_currentProgram) 
    {
        glDeleteProgram(_currentProgram);
        _currentProgram = 0;
    }
    if (_mappingProgram) 
    {
        glDeleteProgram(_mappingProgram);
        _mappingProgram = 0;
    }
    [super dealloc];
}

-(NSString*)rootPath
{
#if (TARGET_IPHONE_SIMULATOR)
	return [[NSBundle mainBundle] resourcePath];
#else
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	return [paths objectAtIndex:0];
#endif
}

-(void)loadSystemShaders
{
    NSString* errorStr = nil;
    
    //
    // load utility shaders
    //
    NSLog(@"LOAD SOLIDCOLOR SHADER");
    _solidColorProgram = loadShaderFile(@"SolidColor", @"SolidColor", &errorStr);
    if (errorStr != nil) { NSLog(@"%@", errorStr); errorStr = nil; }
    NSLog(@"LOAD TEXTURE SHADER");
    _textureProgram = loadShaderFile(@"Texture", @"Texture", &errorStr);
    if (errorStr != nil) { NSLog(@"%@", errorStr); errorStr = nil; }
    NSLog(@"CREATE MAPPING SHADER");
    _mappingProgram = loadShaderFile(@"Mapping", @"Mapping", &errorStr);
    if (errorStr != nil) { NSLog(@"%@", errorStr); errorStr = nil; }
    
    NSLog(@"CREATE BASE SHADER");
    _currentProgram = loadShaderFile(@"Base", @"Base", &errorStr);
    if (errorStr != nil) { NSLog(@"%@", errorStr); errorStr = nil; }
}

-(void)loadFileShaders
{   
    //get the documents directory:
    NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSError* error;
    NSArray* directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    // go through each file and load as shader
    for (NSString* shaderFile in directoryContents)
    {
        if (![[shaderFile pathExtension] isEqualToString:@"fsh"])
            continue;
        NSString* key = [shaderFile stringByDeletingPathExtension];
        
        if ([_shaders objectForKey:key] == nil)
        {
            Shader* newShader = [[Shader alloc] initWithFile:key];
            [_shaders setObject:newShader forKey:key];
        }
    }    
}

-(void)setCurrentShader:(Shader*)shader
{
    _editShaderText = shader.fsText;
    _editSuccess = true;
    _currentShader = shader;
}

-(Shader*)createNewShader
{
    // create new key and shader source
    Shader* newShader = [[Shader alloc] init];
    [_shaders setObject:newShader forKey:newShader.name];
    return newShader;
}

-(void)deleteShader:(Shader*)shader
{
    [_shaders removeObjectForKey:shader.name];
}

// return error
-(NSString*)updateEdittingShader:(NSString*)shaderText
{
    _editShaderText = [shaderText copy];
    NSString* error = [_currentShader updateShaderText:_editShaderText];
    _editSuccess = (error == nil);
    if (_editSuccess) // save shaders
        [self saveUserShaders];
    return error;
}

- (void)saveUserShaders
{
	// save to local storage
	NSLog( @"saving library data" );
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *libraryPath = [documentsDirectory stringByAppendingPathComponent:@"glieseLibrary.plist"];
    NSLog(@"%@", libraryPath);
    
    [NSKeyedArchiver archiveRootObject:_shaders toFile:libraryPath];    
}

- (void)loadUserShaders
{
	// load from local storage
	NSLog( @"loading library data" );
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *libraryPath = [documentsDirectory stringByAppendingPathComponent:@"glieseLibrary.plist"];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:libraryPath])
	{
        _shaders = [NSKeyedUnarchiver unarchiveObjectWithFile:libraryPath];
        [_shaders retain];
	}
}

@end