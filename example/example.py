import math
import python_docstring_annotator

class Shape:
  def __init__(self, color):
    self.color = color
    
  def set_color(self, color):
    self.color = color

class Circle(Shape):
  def __init__(self, radius, color):
    super().__init__(color)
    self.radius = radius
    
  def set_radius(self, radius):
    self.radius = radius
    
  def get_area(self):
    return math.pi * self.radius * self.radius