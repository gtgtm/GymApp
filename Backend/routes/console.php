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
