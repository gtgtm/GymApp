<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::command('gym:notify-expiring-memberships')->dailyAt('08:00');
Schedule::command('gym:notify-pending-payments')->dailyAt('08:15');
Schedule::command('gym:notify-expiring-trials')->twiceDaily(9, 17);
Schedule::command('gym:notify-equipment-maintenance')->dailyAt('08:30');

// Shared hosting has no supervisor for a long-lived worker, so drain the
// database queue (queued notification mail) from the per-minute cron.
Schedule::command('queue:work --stop-when-empty --max-time=50 --tries=3')
    ->everyMinute()
    ->withoutOverlapping();
