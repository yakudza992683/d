#pragma once

#include <entityx/entityx.h>

class MovementSystem : public entityx::System<MovementSystem> {
public:
    MovementSystem(int width, int height) : width(width), height(height) {}

    void update(entityx::EntityManager &entities,
                entityx::EventManager &events,
                double dt) override;

private:
    int width, height;
};

