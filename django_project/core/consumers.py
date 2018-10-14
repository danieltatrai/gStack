from asgiref.sync import async_to_sync as sync
from channels.generic.websocket import JsonWebsocketConsumer


class Websocket(JsonWebsocketConsumer):
    def connect(self):
        if not self.scope['user'].is_authenticated():
            self.close()
            return

        channel_group_name = self.scope['user'].channel_group_name
        for g in ('everybody', channel_group_name):
            sync(self.channel_layer.group_add)(g, self.channel_name)
        self.accept()

    def message(self, event):
        self.send_json(event)
