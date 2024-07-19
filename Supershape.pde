final class Supershape {
  
  int res;                                //Resolution
  PVector vertices[][];                   //Points
  float m_1, n1_1, n2_1, n3_1, a_1, b_1,  //Supershape 1 parameters
        m_2, n1_2, n2_2, n3_2, a_2, b_2;  //Supershape 2 parameters
  
  Supershape(){
    this(0,1,1,1,0,1,1,1,50); //Sphere default
  }
  
  Supershape(float m_1, float n1_1, float n2_1, float n3_1, float m_2, float n1_2, float n2_2, float n3_2, int res) {
    this(m_1, n1_1, n2_1, n3_1, 1, 1, m_2, n1_2, n2_2, n3_2, 1, 1, res);
  }
  
  Supershape(float m_1, float n1_1, float n2_1, float n3_1, float a_1, float b_1, float m_2, float n1_2, float n2_2, float n3_2, float a_2, float b_2, int res) {
    this.res = res;
    this.m_1 = m_1;
    this.n1_1 = n1_1;
    this.n2_1 = n2_1;
    this.n3_1 = n3_1;
    this.a_1 = a_1;
    this.b_1 = b_1;
    this.m_2 = m_2;
    this.n1_2 = n1_2;
    this.n2_2 = n2_2;
    this.n3_2 = n3_2;
    this.a_2 = a_2;
    this.b_2 = b_2;
    vertices = new PVector[res][res];
    for(int i = 0; i < res; i++)
      for(int j = 0; j < res; j++)
        vertices[i][j] = new PVector();
    this.update();
  }
 
  float supershape(float theta, float m, float n1, float n2, float n3, float a, float b) {
    return pow(pow(abs((1/a)*cos(m * theta / 4)), n2) + pow(abs((1/b)*sin(m * theta/4)), n3), -1/n1);
  }
  
  void update() {
    float lon, lat, r1, r2;
    for (int i = 0; i < res; i++) {
      //lat = map(i, 0, res-1, -HALF_PI, HALF_PI);
      lat = ((PI/(res-1))*i)-HALF_PI;
      r2 = supershape(lat, m_2, n1_2, n2_2, n3_2, a_2, b_2);
      //r2 = supershape(lat, 1, 1, 1, 1, 1, 1);
      for (int j = 0; j < res; j++) {
        //lon = map(j, 0, res-1, -PI, PI);
        lon = ((TWO_PI/res)*j)-PI;
        r1 = supershape(lon, m_1, n1_1, n2_1, n3_1, a_1, b_1);
        //r1 = supershape(lon, 2.8f, 1.5f, 7.9f, 2.2f, 1, 1);
        
        vertices[i][j].set(
          r1 * cos(lon) * r2 * cos(lat), //X
          r1 * sin(lon) * r2 * cos(lat), //Y
          r2 * sin(lat));                //Z
      }
    }
  }
  
  void draw() {
    for (int i = 0; i < res - 1; i++) {
      fps.beginShape(TRIANGLE_STRIP);
      for (int j = 0; j < res; j++) {
        fps.vertex(vertices[i][j].x, vertices[i][j].y, vertices[i][j].z);
        fps.vertex(vertices[i+1][j].x, vertices[i+1][j].y, vertices[i+1][j].z);
      }
      fps.vertex(vertices[i][0].x, vertices[i][0].y, vertices[i][0].z);
      fps.vertex(vertices[i+1][0].x, vertices[i+1][0].y, vertices[i+1][0].z);
      fps.endShape();
    }
  }
}
