class Shape {
    constructor(color) {
      this.color = color;
    }
    
    setColor(color) {
      this.color = color;
    }
  }
  
  class Circle extends Shape {
    constructor(radius, color) {
      super(color);
      this.radius = radius;
    }
    
    setRadius(radius) {
      this.radius = radius;
    }
    
    getArea() {
      return Math.PI * this.radius * this.radius;
    }
  }