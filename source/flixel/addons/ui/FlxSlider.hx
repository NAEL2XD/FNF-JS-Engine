package flixel.addons.ui;

#if FLX_MOUSE
import flixel.util.FlxSpriteUtil;

/**
 * A slider GUI element for float and integer manipulation.
 * @author Gama11
 */
class FlxSlider extends FlxSpriteGroup
{
	/**
	 * The horizontal line in the background.
	 */
	public var body:FlxSprite;

	/**
	 * The dragable handle - loadGraphic() to change its graphic.
	 */
	public var handle:FlxSprite;

	/**
	 * The text under the left border - equals minValue by default.
	 */
	public var minLabel:FlxText;

	/**
	 * The text under the right border - equals maxValue by default.
	 */
	public var maxLabel:FlxText;

	/**
	 * A text above the slider that displays its name.
	 */
	public var nameLabel:FlxText;

	/**
	 * A text under the slider that displays the current value.
	 */
	public var valueLabel:FlxText;

	/**
	 * Stores the current value of the variable - updated each frame.
	 */
	public var value:Float;

	/**
	 * Mininum value the variable can be changed to.
	 */
	public var minValue:Float;

	/**
	 * Maximum value the variable can be changed to.
	 */
	public var maxValue:Float;

	/**
	 * How many decimals the variable can have at max. Default is zero,
	 * or "only whole numbers".
	 */
	public var decimals:Int = 0;

	/**
	 * Sound that's played whenever the slider is clicked.
	 */
	public var clickSound:String;

	/**
	 * Sound that's played whenever the slider is hovered over.
	 */
	public var hoverSound:String;

	/**
	 * The alpha value the slider uses when it's hovered over. 1 to turn the effect off.
	 */
	public var hoverAlpha:Float = 0.5;

	/**
	 * A function to be called when the slider was used.
	 * The current relativePos is passed as an argument.
	 */
	public var callback:Float->Void = null;

	/**
	 * Whether the slider sets the variable it tracks. Can be useful to deactivate this in conjunction with callbacks.
	 */
	public var setVariable:Bool = true;

	/**
	 * The expected position of the handle based on the current variable value.
	 */
	public var expectedPos(get, never):Float;

	/**
	 * The position of the handle relative to the slider / max value.
	 */
	public var relativePos(get, never):Float;

	/**
	 * Stores the variable the slider controls.
	 */
	public var varString(default, set):String;

	/**
	 * The dragable area for the handle. Is configured automatically.
	 */
	var _bounds:FlxRect;

	/**
	 * The width of the slider.
	 */
	var _width:Int;

	/**
	 * The height of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	var _height:Int;

	/**
	 * The thickness of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	var _thickness:Int;

	/**
	 * The color of the slider - make sure to call createSlider() if you
	 * want to change this.
	 */
	var _color:FlxColor;

	/**
	 * The color of the handle - make sure to call createSlider() if you
	 * want to change this.
	 */
	var _handleColor:FlxColor;

	/**
	 * Stores a reference to parent object.
	 */
	var _object:Dynamic;

	/**
	 * Helper var for callbacks.
	 */
	var _lastPos:Float;

	/**
	 * Helper variable to avoid the clickSound playing every frame.
	 */
	var _justClicked:Bool = false;

	/**
	 * Helper variable to avoid the hoverSound playing every frame.
	 */
	var _justHovered:Bool = false;

	/**
	 * Creates a new FlxSlider.
	 *
	 * @param	Object 			Reference to the parent object of the variable
	 * @param	VarString 		Variable that the slider controls
	 * @param	X				x Position
	 * @param	Y 				y Position
	 * @param	MinValue 		Mininum value the variable can be changed to
	 * @param	MaxValue 		Maximum value the variable can be changed to
	 * @param	Width 			Width of the slider
	 * @param	Height 			Height of the slider
	 * @param	Thickness 		Thickness of the slider
	 * @param	Color 			Color of the slider background and all texts except for valueText showing the current value
	 * @param	HandleColor 	Color of the slider handle and the valueText showing the current value
	 */
	public function new(Object:Dynamic, VarString:String, X:Float = 0, Y:Float = 0, MinValue:Float = 0, MaxValue:Float = 10, Width:Int = 100, Height:Int = 15,
			Thickness:Int = 3, Color:Int = 0xFF000000, HandleColor:Int = 0xFF828282)
	{
		super();

		x = X;
		y = Y;

		if (MinValue == MaxValue)
		{
			FlxG.log.error("FlxSlider: MinValue and MaxValue can't be the same (" + MinValue + ")");
		}

		// Determine the amount of decimals to show
		decimals = FlxMath.getDecimals(MinValue);

		if (FlxMath.getDecimals(MaxValue) > decimals)
		{
			decimals = FlxMath.getDecimals(MaxValue);
		}

		decimals++;

		// Assign all those constructor vars
		minValue = MinValue;
		maxValue = MaxValue;
		_object = Object;
		varString = VarString;
		_width = Width;
		_height = Height;
		_thickness = Thickness;
		_color = Color;
		_handleColor = HandleColor;

		// Create the slider
		createSlider();
	}

	/**
	 * Initially creates the slider with all its objects.
	 */
	function createSlider():Void
	{
		offset.set(7, 18);
		_bounds = FlxRect.get(x + offset.x, y + offset.y, _width, _height);

		// Creating the "body" of the slider
		body = new FlxSprite(offset.x, offset.y);
		var colorKey:String = "slider:W=" + _width + "H=" + _height + "C=" + _color.toHexString() + "T=" + _thickness;
		body.makeGraphic(_width, _height, 0, false, colorKey);
		body.scrollFactor.set();
		FlxSpriteUtil.drawLine(body, 0, _height / 2, _width, _height / 2, {color: _color, thickness: _thickness});

		handle = new FlxSprite(offset.x, offset.y);
		handle.makeGraphic(_thickness, _height, _handleColor);
		handle.scrollFactor.set();

		// Creating the texts
		nameLabel = new FlxText(offset.x, 0, _width, varString);
		nameLabel.alignment = "center";
		nameLabel.color = _color;
		nameLabel.scrollFactor.set();

		var textOffset:Float = _height + offset.y + 3;

		valueLabel = new FlxText(offset.x, textOffset, _width);
		valueLabel.alignment = "center";
		valueLabel.color = _handleColor;
		valueLabel.scrollFactor.set();

		minLabel = new FlxText(-50 + offset.x, textOffset, 100, Std.string(minValue));
		minLabel.alignment = "center";
		minLabel.color = _color;
		minLabel.scrollFactor.set();

		maxLabel = new FlxText(_width - 50 + offset.x, textOffset, 100, Std.string(maxValue));
		maxLabel.alignment = "center";
		maxLabel.color = _color;
		maxLabel.scrollFactor.set();

		// Add all the objects
		add(body);
		add(handle);
		add(nameLabel);
		add(valueLabel);
		add(minLabel);
		add(maxLabel);
	}

	override public function update(elapsed:Float):Void
	{
		// Clicking and sound logic
		if (mouseInRect(_bounds))
		{
			if (hoverAlpha != 1)
			{
				alpha = hoverAlpha;
			}

			#if FLX_SOUND_SYSTEM
			if (hoverSound != null && !_justHovered)
			{
				FlxG.sound.play(hoverSound);
			}
			#end

			_justHovered = true;

			if (FlxG.mouse.pressed)
			{
				handle.x = FlxG.mouse.getPositionInCameraView(camera).x;
				updateValue();

				#if FLX_SOUND_SYSTEM
				if (clickSound != null && !_justClicked)
				{
					FlxG.sound.play(clickSound);
					_justClicked = true;
				}
				#end
			}
			if (!FlxG.mouse.pressed)
			{
				_justClicked = false;
			}
		}
		else
		{
			if (hoverAlpha != 1)
			{
				alpha = 1;
			}

			_justHovered = false;
		}

		// Update the target value whenever the slider is being used
		if ((FlxG.mouse.pressed) && (mouseInRect(_bounds)))
		{
			updateValue();
		}

		// Update the value variable
		if ((varString != null) && (Reflect.getProperty(_object, varString) != null))
		{
			value = Reflect.getProperty(_object, varString);
		}

		// Changes to value from outside update the handle pos
		if (handle.x != expectedPos)
		{
			handle.x = expectedPos;
		}

		// Finally, update the valueLabel
		valueLabel.text = Std.string(FlxMath.roundDecimal(value, decimals));

		super.update(elapsed);
	}

	private function mouseInRect(rect:flixel.math.FlxRect)
	{
		if (FlxMath.pointInFlxRect(FlxG.mouse.getPositionInCameraView(camera).x,FlxG.mouse.getPositionInCameraView(camera).y,rect)) return true;
		else return false;
	}

	/**
	 * Function that is called whenever the slider is used to either update the variable tracked or call the Callback function.
	 */
	function updateValue():Void
	{
		if (_lastPos != relativePos)
		{
			if ((setVariable) && (varString != null))
			{
				Reflect.setProperty(_object, varString, (relativePos * (maxValue - minValue)) + minValue);
			}

			_lastPos = relativePos;

			if (callback != null)
				callback(relativePos);
		}
	}

	/**
	 * Handy function for changing the textfields.
	 *
	 * @param 	Name 		Text of nameLabel - null to hide
	 * @param 	Value	 	Whether to show the valueText or not
	 * @param 	Min 		Text of minLabel - null to hide
	 * @param 	Max 		Text of maxLabel - null to hide
	 * @param 	Size 		Size to use for the texts
	 */
	public function setTexts(Name:String, Value:Bool = true, ?Min:String, ?Max:String, Size:Int = 8):Void
	{
		if (Name == null)
		{
			nameLabel.visible = false;
		}
		else
		{
			nameLabel.text = Name;
			nameLabel.visible = true;
		}

		if (Min == null)
		{
			minLabel.visible = false;
		}
		else
		{
			minLabel.text = Min;
			minLabel.visible = true;
		}

		if (Max == null)
		{
			maxLabel.visible = false;
		}
		else
		{
			maxLabel.text = Max;
			maxLabel.visible = true;
		}

		if (!Value)
		{
			valueLabel.visible = false;
		}
		else
		{
			valueLabel.visible = true;
		}

		nameLabel.size = Size;
		valueLabel.size = Size;
		minLabel.size = Size;
		maxLabel.size = Size;
	}

	/**
	 * Cleaning up memory.
	 */
	override public function destroy():Void
	{
		body = FlxDestroyUtil.destroy(body);
		handle = FlxDestroyUtil.destroy(handle);
		minLabel = FlxDestroyUtil.destroy(minLabel);
		maxLabel = FlxDestroyUtil.destroy(maxLabel);
		nameLabel = FlxDestroyUtil.destroy(nameLabel);
		valueLabel = FlxDestroyUtil.destroy(valueLabel);

		_bounds = FlxDestroyUtil.put(_bounds);

		super.destroy();
	}

	function get_expectedPos():Float
	{
		var pos:Float = x + offset.x + ((_width - handle.width) * ((value - minValue) / (maxValue - minValue)));

		// Make sure the pos stays within the bounds
		if (pos > x + _width + offset.x)
		{
			pos = x + _width + offset.x;
		}
		else if (pos < x + offset.x)
		{
			pos = x + offset.x;
		}

		return pos;
	}

	function get_relativePos():Float
	{
		var pos:Float = (handle.x - x - offset.x) / (_width - handle.width);

		// Relative position can't be bigger than 1
		if (pos > 1)
		{
			pos = 1;
		}

		return pos;
	}

	function set_varString(Value:String):String
	{
		try
		{
			Reflect.getProperty(_object, Value);
			varString = Value;
		}
		catch (e:Dynamic)
		{
			FlxG.log.error("Could not create FlxSlider - '" + Value + "' is not a valid field of '" + _object + "'");
			varString = null;
		}

		return Value;
	}

	override function set_x(value:Float):Float
	{
		super.set_x(value);
		updateBounds();
		return x = value;
	}

	override function set_y(value:Float):Float
	{
		super.set_y(value);
		updateBounds();
		return y = value;
	}

	inline function updateBounds()
	{
		if (_bounds != null)
			_bounds.set(x + offset.x, y + offset.y, _width, _height);
	}
}
#end
