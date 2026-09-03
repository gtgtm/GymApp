"use client";

import { Bell, Check } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  useNotifications,
  useMarkAllNotificationsRead,
  useMarkNotificationRead,
} from "@/hooks/use-notifications";

export function NotificationBell() {
  const { data } = useNotifications();
  const markRead = useMarkNotificationRead();
  const markAllRead = useMarkAllNotificationsRead();

  const notifications = data?.notifications ?? [];
  const unreadCount = data?.unreadCount ?? 0;

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        render={
          <Button variant="ghost" size="icon" className="relative">
            <Bell className="h-4 w-4" />
            {unreadCount > 0 && (
              <Badge className="absolute -right-1 -top-1 h-4 min-w-4 justify-center rounded-full bg-red-600 px-1 text-[10px] text-white">
                {unreadCount > 9 ? "9+" : unreadCount}
              </Badge>
            )}
          </Button>
        }
      />
      <DropdownMenuContent align="end" className="w-80">
        <div className="flex items-center justify-between px-2 py-1.5">
          <span className="text-xs font-medium text-muted-foreground">Notifications</span>
          {unreadCount > 0 && (
            <Button
              variant="ghost"
              size="xs"
              onClick={() => void markAllRead.mutateAsync()}
              disabled={markAllRead.isPending}
            >
              <Check className="h-3 w-3" />
              Mark all read
            </Button>
          )}
        </div>
        <DropdownMenuSeparator />
        <div className="max-h-80 overflow-y-auto">
          {notifications.length === 0 && (
            <p className="px-2 py-4 text-center text-sm text-muted-foreground">
              No notifications yet.
            </p>
          )}
          {notifications.map((notification) => (
            <DropdownMenuItem
              key={notification.id}
              className="flex flex-col items-start gap-0.5 whitespace-normal py-2"
              onClick={() => {
                if (!notification.read_at) void markRead.mutateAsync(notification.id);
              }}
            >
              <div className="flex w-full items-center gap-2">
                {!notification.read_at && (
                  <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-primary" />
                )}
                <span className="text-sm font-medium">{notification.title}</span>
              </div>
              {notification.body && (
                <p className="pl-3.5 text-xs text-muted-foreground line-clamp-2">
                  {notification.body}
                </p>
              )}
            </DropdownMenuItem>
          ))}
        </div>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
