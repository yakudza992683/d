#ifdef _WIN32
#  include <GL/gl.h>
#else
#  ifdef __APPLE__
#    include <OpenGL/gl.h>
#  else
#    include <GL/gl.h>
#  endif
#endif

#include <components/appearance/appearance.h>
#include <components/mass.h>
#include <components/position.h>

#include "render.h"

void RenderSystem::update(entityx::EntityManager &entities,
                          entityx::EventManager &events,
                          double dt) {
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    for (auto entity : entities.entities_with_components<Appearance>()) {
        if (entity.valid()) {
            auto position   = entity.component<Position>();
            auto appearance = entity.component<Appearance>();

            glPushMatrix();
            if (position) {
                glTranslatef(position->x, position->y, -500);
                glRotatef(position->rotation,
                          position->rotation_axis_x,
                          position->rotation_axis_y,
                          position->rotation_axis_z);
            }
            appearance->render(entity, dt);
            glPopMatrix();
        }
    }
}

