package example;

class Shape {
  protected String color;
  
  public Shape(String color) {
    this.color = color;
  }
  
  public void setColor(String color) {
    this.color = color;
  }
}

class Circle extends Shape {
  protected double radius;
  
  public Circle(double radius, String color) {
    super(color);
    this.radius = radius;
  }
  
  public void setRadius(double radius) {
    this.radius = radius;
  }
  
  public double getArea() {
    return Math.PI * radius * radius;
  }
}