package org.anddev.andengine.mmcomix.scene;

import org.anddev.andengine.entity.IEntity;
import org.anddev.andengine.entity.modifier.LoopEntityModifier;
import org.anddev.andengine.entity.modifier.ScaleModifier;
import org.anddev.andengine.entity.modifier.SequenceEntityModifier;
import org.anddev.andengine.entity.modifier.IEntityModifier.IEntityModifierListener;
import org.anddev.andengine.entity.scene.menu.MenuScene;
import org.anddev.andengine.entity.sprite.Sprite;
import org.anddev.andengine.entity.text.Text;
import org.anddev.andengine.extra.Enviroment;
import org.anddev.andengine.extra.ExtraScene;
import org.anddev.andengine.extra.Resource;
import org.anddev.andengine.input.touch.TouchEvent;
import org.anddev.andengine.opengl.font.Font;
import org.anddev.andengine.opengl.texture.region.TextureRegion;
import org.anddev.andengine.util.modifier.IModifier;

import com.openfeint.api.ui.Dashboard;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;

public class MainMenu extends ExtraScene {
	
	private Font fontMainMenu;
	
	private TextureRegion mBack;
	private TextureRegion mTitle;
	
	private int mIndex;
	
	@Override
	public MenuScene createMenu() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void createScene() {
		this.mBack = Resource.getTexture(512, 1024, "back");
		Sprite back = new Sprite(0, 0, this.mBack);
		getChild(ExtraScene.GAME_LAYER).attachChild(back);
		
		int x = Enviroment.getInstance().getScreenWidth() / 2;
		
		this.mTitle = Resource.getTexture(512, 256, "title");
		Sprite title = new Sprite(0, 0, this.mTitle);
		title.setPosition(x - title.getWidthScaled() / 2, 90);
		title.registerEntityModifier(
				new LoopEntityModifier(
						null, 
						-1, 
						null,
						new SequenceEntityModifier(
								new ScaleModifier(0.7f, 1f, 1.04f),
								new ScaleModifier(0.7f, 1.04f, 1f)
						)
				)
		);
		getChild(ExtraScene.GAME_LAYER).attachChild(title);
		
		this.fontMainMenu = Resource.getFont(512, 512, "akaDylan Plain", 44, 3, Color.WHITE, Color.BLACK);
		
		this.mIndex = 382;
		
    	Text play = new Text(0, 0, this.fontMainMenu, "PLAY");
    	play.setPosition(x - play.getWidthScaled() / 2, this.mIndex);
    	
    	Text score = new Text(0, 0, this.fontMainMenu, "SCORE");
    	score.setPosition(x - score.getWidthScaled() / 2, this.mIndex + 90);
    	
    	Text more = new Text(0, 0, this.fontMainMenu, "MORE GAMES");
    	more.setPosition(x - more.getWidthScaled() / 2, this.mIndex + 180);
    	
    	getChild(ExtraScene.GAME_LAYER).attachChild(play);
    	getChild(ExtraScene.GAME_LAYER).attachChild(score);
    	getChild(ExtraScene.GAME_LAYER).attachChild(more);
    	
    	registerTouchArea(play);
    	registerTouchArea(score);
    	registerTouchArea(more);
	}

	@Override
	public void endScene() {
		Enviroment.getInstance().setScene(new Game());
	}

	@Override
	public void manageAreaTouch(final ITouchArea pTouchArea) {
		final Text item = (Text) pTouchArea;
		item.setColor(1f, 0.7f, 0.7f);
		
		item.registerEntityModifier(
				new SequenceEntityModifier(
						new IEntityModifierListener() {
							@Override
							public void onModifierFinished(IModifier<IEntity> pModifier, IEntity pItem) {
								item.setColor(1.0f, 1.0f, 1.0f);
								MainMenu.this.execute(pTouchArea);
							}
						},
						new ScaleModifier(0.1f, 1f, 1.3f),
						new ScaleModifier(0.1f, 1.3f, 1f)
		));
	}

	private void execute(ITouchArea pTouchArea) {
		Text item = (Text) pTouchArea;
		if ((int) item.getY() == this.mIndex) {
			Enviroment.getInstance().nextScene();
		} else if ((int) item.getY() == this.mIndex + 90) {
			try {
				Dashboard.open();
			} catch (Exception e) {
			}
		} else if ((int) item.getY() == this.mIndex + 180) {
			try{
				Enviroment.getInstance().getContext().startActivity(new Intent (Intent.ACTION_VIEW, Uri.parse("market://details?id=org.anddev.andengine.braingame")));
			} catch (ActivityNotFoundException e) {
			}
		}
	}
	
	@Override
	public void manageSceneTouch(TouchEvent pSceneTouchEvent) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void startScene() {
		// TODO Auto-generated method stub
		
	}

}
