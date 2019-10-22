package org.graalvm.demos.micronaut.service.todo;

import io.lettuce.core.KeyValue;
import io.lettuce.core.ScanArgs;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.api.sync.RedisCommands;
import io.micronaut.jackson.serialize.JacksonObjectSerializer;
import org.graalvm.demos.micronaut.service.api.v1.Todo;

import javax.inject.Inject;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class RedisTodoService implements TodoService {
    @Inject StatefulRedisConnection<String, String> connection;
    @Inject JacksonObjectSerializer jsonSerializer;

    private static SecureRandom RANDOM_GEN = new SecureRandom();

    @Override
    public Todo create(Todo todo) throws ServiceException {
        RedisCommands<String, String> command = connection.sync();
        byte[] rand = new byte[32];
        RANDOM_GEN.nextBytes(rand);
        String uuid = Base64.getUrlEncoder().encodeToString(rand).substring(0,7);
        todo.setId(uuid);
        if (todo.getTimeCreated() == null) {
            todo.setTimeCreated(new Date());
        }

        Optional<byte[]> serialize = jsonSerializer.serialize(todo);
        if (!serialize.isPresent()) {
            throw new ServiceException("Can not serialize Todo object when saving to redis");
        }

        command.set(todo.getId(), new String(serialize.get()));
        return todo;
    }

    @Override
    public Todo update(String todoId, Todo newTodo) throws ServiceException {
        return null;
    }

    @Override
    public void remove(String todoId) throws ServiceException {
        RedisCommands<String, String> command = connection.sync();
        command.del(todoId);
    }

    @Override
    public Collection<Todo> listTodos(String userId, int limit) throws ServiceException {
        RedisCommands<String, String> command = connection.sync();
        List<String> keys = command.scan(ScanArgs.Builder.limit(limit)).getKeys();
        if (keys.size() == 0) {
            return Collections.emptyList();
        }

        List<KeyValue<String, String>> values = command.mget(keys.toArray(new String[]{}));
        List<Todo> todos = new ArrayList<>();
        for(KeyValue<String, String> kv : values) {
            String jsonValue = kv.getValue();
            Optional<Todo> todo = jsonSerializer.deserialize(jsonValue.getBytes(), Todo.class);
            todo.ifPresent(todos::add);
        }
        return todos;
    }

    @Override
    public Todo get(String id) throws ServiceException {
        RedisCommands<String, String> command = connection.sync();
        Optional<Todo> object = jsonSerializer.deserialize(command.get(id).getBytes(), Todo.class);
        return object.get();
    }
}
