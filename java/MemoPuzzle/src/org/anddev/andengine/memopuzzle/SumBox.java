package org.anddev.andengine.memopuzzle;

import java.util.LinkedList;

import org.anddev.andengine.entity.primitive.Rectangle;
import org.anddev.andengine.entity.scene.Scene;
import org.anddev.andengine.entity.scene.background.ColorBackground;
import org.anddev.andengine.entity.sprite.Sprite;
import org.anddev.andengine.extension.physics.box2d.PhysicsConnector;
import org.anddev.andengine.extension.physics.box2d.PhysicsFactory;
import org.anddev.andengine.extension.physics.box2d.PhysicsWorld;
import org.anddev.andengine.opengl.texture.Texture;
import org.anddev.andengine.opengl.texture.TextureOptions;
import org.anddev.andengine.opengl.texture.region.TextureRegion;
import org.anddev.andengine.opengl.texture.region.TextureRegionFactory;

import android.hardware.SensorManager;

import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.physics.box2d.Body;
import com.badlogic.gdx.physics.box2d.FixtureDef;
import com.badlogic.gdx.physics.box2d.BodyDef.BodyType;

public class SumBox extends Scene {
	private static final int SUP = 9;
	private static final int INF = 1;
	
	public SumBox(MemoPuzzle game) {
		super(1);
		
    	// fisica
    	PhysicsWorld mPhysicsWorld = new PhysicsWorld(new Vector2(0, SensorManager.GRAVITY_EARTH), false);
    	registerUpdateHandler(mPhysicsWorld);
    	
		// background
        setBackground(new ColorBackground(1, 1, 1));
        
        // texture
    	final Texture tex1  = new Texture(128, 128, TextureOptions.BILINEAR_PREMULTIPLYALPHA);
    	final TextureRegion tex1reg = TextureRegionFactory.createFromAsset(tex1, game, "gfx/1.png", 0, 0);
    	
    	game.getEngine().getTextureManager().loadTexture(tex1); // prende + text con la ,
    	
        // objects
    	final Rectangle ground = new Rectangle(0, MemoPuzzle.CAMERA_HEIGHT, MemoPuzzle.CAMERA_WIDTH, 2);  		
		final FixtureDef wallFixtureDef = PhysicsFactory.createFixtureDef(0, 0.5f, 0.5f);
    	PhysicsFactory.createBoxBody(mPhysicsWorld, ground, BodyType.StaticBody, wallFixtureDef);
       	getLastChild().attachChild(ground);
       	
    	int num = 5;
        for (int i = 1; i <= num; i++) {
        	int range = SUP - INF + 1;
        	int value = (int)(range * Math.random()) + INF;
        	
        	final Sprite face1 = new Sprite(185, - i * 150, tex1reg);
        	switch (value%3) {
        		case 0: 
        			face1.setColor(1.0f, (float)value/SUP, (float)value/SUP);
        			break;
        		case 1: 
        			face1.setColor((float)value/SUP, 1.0f, (float)value/SUP);
        			break;
        		case 2: 
        			face1.setColor((float)value/SUP, (float)value/SUP, 1.0f);
        			break;
        	}
        	final FixtureDef objectFixtureDef = PhysicsFactory.createFixtureDef(1, 0.5f, 0.5f);
        	final Body body1 = PhysicsFactory.createCircleBody(mPhysicsWorld, face1, BodyType.DynamicBody, objectFixtureDef);
        	getLastChild().attachChild(face1);        	
        	mPhysicsWorld.registerPhysicsConnector(new PhysicsConnector(face1, body1, true, false)); // false updata la rotazione
        }
	}
	
}
