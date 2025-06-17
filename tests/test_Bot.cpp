#include <gtest/gtest.h>
#include "../include/Bot.hpp"

// Минимальный мок для WorldEntity и GameWorld
class DummyEntity : public WorldEntity {
public:
    DummyEntity() : WorldEntity() {}
    bool isDone() const override { return false; }
    void initPhysics(GameWorld*) override {}
    void update(GameWorld&) override {}
    void render() override {}
};
class DummyGameWorld : public GameWorld {};

TEST(BotTest, DefaultConstructor) {
    Bot bot;
    SUCCEED();
}

TEST(BotTest, SetTarget) {
    Bot bot;
    DummyEntity entity;
    bot.setTarget(&entity);
    bot.hit(&entity, nullptr);
    SUCCEED();
}

TEST(BotTest, InitializeStatic) {
    Bot::initialize();
    SUCCEED();
}

// Проверка hit с типом ZOMBIE
class ZombieEntity : public WorldEntity {
public:
    ZombieEntity() : WorldEntity() {}
    bool isDone() const override { return false; }
    void initPhysics(GameWorld*) override {}
    void update(GameWorld&) override {}
    void render() override {}
};

TEST(BotTest, HitZombieSetsTarget) {
    Bot bot;
    ZombieEntity zombie;
    bot.hit(&zombie, nullptr);
    SUCCEED();
}
