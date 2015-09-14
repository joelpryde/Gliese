//
//  ShaderManager.h
//  jecTile
//
//  Created by Joel Pryde on 11/29/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Shader;

@interface ShaderManager : NSObject
{
    NSMutableDictionary* _shaders;
    
    // special shaders
    GLuint _textureProgram, _solidColorProgram, _mappingProgram;
        
    // current shader for each channel
    GLuint _currentProgram;
    Shader* _currentShader;
    NSString* _editShaderText;
    bool _editSuccess;
    NSString* _templateSource;
}

@property (nonatomic, retain) NSMutableDictionary* shaders;

@property (readonly) GLuint textureProgram;
@property (readonly) GLuint solidColorProgram;
@property (readonly) GLuint currentProgram;
@property (readonly) GLuint mappingProgram;

@property (readonly) Shader* currentShader;
@property (readonly) NSString* editShaderText;
@property (readonly) bool editSuccess;
@property (readonly) NSString* templateSource;

+ (ShaderManager*)Instance;

-(NSString*)rootPath;
-(void)loadSystemShaders;
-(void)loadFileShaders;

// editting shaders
-(void)setCurrentShader:(Shader*)shader;
-(NSString*)updateEdittingShader:(NSString*)shaderText;
-(Shader*)createNewShader;
-(void)deleteShader:(Shader*)shader;

- (void)saveUserShaders;
- (void)loadUserShaders;

@end
