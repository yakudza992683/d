#ifdef _WIN32
#  include <GL/gl.h>
#else
#  ifdef __APPLE__
#    include <OpenGL/gl.h>
#  else
#    include <GL/gl.h>
#  endif
#endif
#include "laser.h"

void Laser::render(float dt) {
    const GLfloat mat_emission[] = { 0.5f, 1.0f, 1.0f, 1.0f };

    glMaterialfv(GL_FRONT, GL_EMISSION, mat_emission);

    glBegin(GL_LINES);
    glVertex3f(0, 0,  0);
    glVertex3f(0, 30, 0);
    glEnd();
}

