"use client";

import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import type { BodyMeasurement } from "@/lib/api-types";

export function ProgressChart({ measurements }: { measurements: BodyMeasurement[] }) {
  const chartData = measurements.map((entry) => ({
    date: new Date(entry.recorded_date).toLocaleDateString("en-IN", {
      day: "2-digit",
      month: "short",
    }),
    weight: entry.weight_kg ? Number(entry.weight_kg) : null,
    bmi: entry.bmi ? Number(entry.bmi) : null,
  }));

  return (
    <div className="h-64 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={chartData} margin={{ top: 8, right: 16, bottom: 0, left: -16 }}>
          <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
          <XAxis dataKey="date" fontSize={12} />
          <YAxis fontSize={12} />
          <Tooltip />
          <Line type="monotone" dataKey="weight" stroke="#0ea5e9" name="Weight (kg)" strokeWidth={2} />
          <Line type="monotone" dataKey="bmi" stroke="#f59e0b" name="BMI" strokeWidth={2} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
