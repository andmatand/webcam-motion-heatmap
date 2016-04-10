local function smallColorRange(largeColor)
   return largeColor / 255
end

local function largeColorRange(smallColor)
   return math.floor(smallColor * 255 + 0.5)
end

local function pack(...)
   return arg
end

local function rgbToHsv(r, g, b)
   -- convert rgb from 0-255, to 0-1
   r = smallColorRange(r)
   g = smallColorRange(g)
   b = smallColorRange(b)
   local h, s, v
   local min = math.min(r, g, b)
   local max  = math.max(r, g, b)
   local delta = max - min
   -- value
   v = max
   -- saturation
   if delta ~= 0 then -- we know max won't be zero, as min can't be less than zero and the difference is not 0
      s = delta / max
   else
      h = -1
      s = 0
      return h, s, v
   end
   -- hue
   if r == max then -- yellow <-> magenta
      h = (g - b) / delta
   elseif g == max then -- cyan <-> yellow
      h = 2 + (b - r) / delta
   else -- magenta <-> cyan
      h = 4 + (r - g) / delta
   end
   h = h * 60 -- 60 degrees
   if h < 0 then
      h = h + 360
   end
   return h, s, v
end

local function hsvToRgb(h, s, v)
   local r, g, b
   if s == 0 then -- monochromatic
      -- restore colors from 0-1, to 0-255
      r = largeColorRange(v)
      g = largeColorRange(v)
      b = largeColorRange(v)
      return r, g, b
   end
   
   h = h / 60 -- sector of wheel
   local i = math.floor(h)
   local f = h - i -- factorial part of h
   local p = v * (1 - s)
   local q = v * (1 - s * f)
   local t = v * (1 - s * (1 - f))
   
   if i == 0 then
      r = v
      g = t
      b = p
   elseif i == 1 then
      r = q
      g = v
      b = p
   elseif i == 2 then
      r = p
      g = v
      b = t
   elseif i == 3 then
      r = p
      g = q
      b = v
   elseif i == 4 then
      r = t
      g = p
      b = v
   else
      r = v
      g = p
      b = q
   end
   
   r = largeColorRange(r)
   g = largeColorRange(g)
   b = largeColorRange(b)
   
   return r, g, b
end

local function gradientColor(color1, color2, proportion)
   if proportion < 0 or proportion > 1 then 
      error("Gradient proportion must be between 0 and 1.") 
   end
   
   local h1, s1, v1 = rgbToHsv(unpack(color1))
   local h2, s2, v2 = rgbToHsv(unpack(color2))
   -- find difference between two values, and advance proportion of that difference from value 1
   local hDiff = (h2 - h1) * proportion
   local sDiff = (s2 - s1) * proportion
   local vDiff = (v2 - v1) * proportion
   
   local gradH = hDiff + h1
   local gradS = sDiff + s1
   local gradV = vDiff + v1
   
   return pack(hsvToRgb(gradH, gradS, gradV))
end

return {
   rgbToHsv=rgbToHsv,
   hsvToRgb=hsvToRgb,
   gradientColor=gradientColor,
}
