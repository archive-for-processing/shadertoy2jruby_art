attr_reader :last_mouse_position, :mouse_click_state, :mouse_dragged
attr_reader :previous_time, :wrapper, :start
# uniform iChannelTime[4]         # channel playback time (in seconds)
# uniform vec3  iChannelResolution[4] # channel resolution (in pixels)
# uniform samplerXX iChannel0..3 # input channel. XX = 2D/Cube

def settings
  size(640, 360, P2D)
end

def setup
  sketch_title 'Shadertoy Default Wrapper'
  @previous_time = 0.0
  @mouse_dragged = false
  @mouse_click_state = 0.0
  # Load the shader file from the "data" folder
  @wrapper = load_shader(data_path('default_shader.glsl'))
  # Assume the dimension of the window will not change over time
  wrapper.set('iResolution', width.to_f, height.to_f, 0.0)
  @last_mouse_position = Vec2D.new(mouse_x, mouse_y)
  @start = java.lang.System.current_time_millis
end

def draw
  # shader playback time (in seconds)
  current_time = (java.lang.System.current_time_millis - start) / 1000.0
  wrapper.set('iTime', current_time)
  # render time (in seconds)
  time_delta = current_time - previous_time
  @previous_time = current_time
  wrapper.set('iDeltaTime', time_delta)
  # shader playback frame
  wrapper.set('iFrame', frame_count)
  # mouse pixel coords. xy: current (if MLB down), zw: click
  if mouse_pressed?
    @last_mouse_position = Vec2D.new(mouse_x, mouse_y)
    @mouse_click_state = 1.0
  else
    @mouse_click_state = 0.0
  end
  wrapper.set('iMouse', last_mouse_position.x, last_mouse_position.y, mouse_click_state, mouse_click_state)
  # Set the date
  # Note that iDate.y and iDate.z contain month-1 and day-1 respectively,
  # while x does contain the year (see: https://www.shadertoy.com/view/ldKGRR)
  jdate = Time.now.to_java
  wrapper.set('iDate', jdate.get_year + 1990, jdate.get_month - 1, jdate.get_date - 1, jdate.seconds)
  # This uniform is undocumented so I have no idea what the range is
  wrapper.set('iFrameRate', frame_rate)
  # Apply the specified shader to any geometry drawn from this point
  shader(wrapper)
  # Draw the output of the shader onto a rectangle that covers the whole viewport.
  rect(0, 0, width, height)
end
