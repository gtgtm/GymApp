"use client";

import { useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { DateRangePicker } from "@/components/reports/date-range-picker";
import { ExportButtons } from "@/components/reports/export-buttons";
import {
  useFinancialReport,
  useMembersReport,
  useAttendanceReport,
  useTrainerReport,
  useSalesReport,
} from "@/hooks/use-reports";

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

function monthStartIso(): string {
  const date = new Date();
  return new Date(date.getFullYear(), date.getMonth(), 1).toISOString().slice(0, 10);
}

export default function ReportsPage() {
  const [range, setRange] = useState({ from: monthStartIso(), to: todayIso() });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Reports</h1>
        <DateRangePicker range={range} onChange={setRange} />
      </div>

      <Tabs defaultValue="financial">
        <TabsList>
          <TabsTrigger value="financial">Financial</TabsTrigger>
          <TabsTrigger value="members">Members</TabsTrigger>
          <TabsTrigger value="attendance">Attendance</TabsTrigger>
          <TabsTrigger value="trainers">Trainers</TabsTrigger>
          <TabsTrigger value="sales">Sales</TabsTrigger>
        </TabsList>

        <TabsContent value="financial">
          <FinancialReportTab range={range} />
        </TabsContent>
        <TabsContent value="members">
          <MembersReportTab range={range} />
        </TabsContent>
        <TabsContent value="attendance">
          <AttendanceReportTab range={range} />
        </TabsContent>
        <TabsContent value="trainers">
          <TrainersReportTab />
        </TabsContent>
        <TabsContent value="sales">
          <SalesReportTab range={range} />
        </TabsContent>
      </Tabs>
    </div>
  );
}

function FinancialReportTab({ range }: { range: { from: string; to: string } }) {
  const { data, isLoading } = useFinancialReport(range);

  if (isLoading || !data) return <Skeleton className="h-64 w-full" />;

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <ExportButtons report="financial" range={range} includePdf />
      </div>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Revenue</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">
            ₹{data.summary.revenue.toLocaleString("en-IN")}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Expenses</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">
            ₹{data.summary.expenses.toLocaleString("en-IN")}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Profit</CardTitle>
          </CardHeader>
          <CardContent
            className={`text-2xl font-bold ${data.summary.profit >= 0 ? "text-emerald-600" : "text-red-600"}`}
          >
            ₹{data.summary.profit.toLocaleString("en-IN")}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Payment Method Breakdown</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Method</TableHead>
                <TableHead>Amount</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {Object.entries(data.summary.payment_method_breakdown).length === 0 && (
                <TableRow>
                  <TableCell colSpan={2} className="text-center text-muted-foreground">
                    No payments in this period.
                  </TableCell>
                </TableRow>
              )}
              {Object.entries(data.summary.payment_method_breakdown).map(([method, amount]) => (
                <TableRow key={method}>
                  <TableCell className="capitalize">{method.replace("_", " ")}</TableCell>
                  <TableCell>₹{amount}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

function MembersReportTab({ range }: { range: { from: string; to: string } }) {
  const { data, isLoading } = useMembersReport(range);

  if (isLoading || !data) return <Skeleton className="h-64 w-full" />;

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <ExportButtons report="members" range={range} />
      </div>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">New Members</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{data.summary.new_members}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Active Members</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{data.summary.active_members}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Renewals</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{data.summary.renewals}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Churn Rate</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{data.summary.churn_rate}%</CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Plan Distribution</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Plan</TableHead>
                <TableHead>Active Members</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.plan_distribution.map((row) => (
                <TableRow key={row.plan_name}>
                  <TableCell>{row.plan_name}</TableCell>
                  <TableCell>{row.count}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

function AttendanceReportTab({ range }: { range: { from: string; to: string } }) {
  const { data, isLoading } = useAttendanceReport(range);

  if (isLoading || !data) return <Skeleton className="h-64 w-full" />;

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <ExportButtons report="attendance" range={range} />
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Attendance by Day of Week</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Day</TableHead>
                <TableHead>Visits</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.by_day_of_week.map((row) => (
                <TableRow key={row.day}>
                  <TableCell>{row.day}</TableCell>
                  <TableCell>{row.count}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Member-wise Attendance</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Member</TableHead>
                <TableHead>Visits</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.member_wise.length === 0 && (
                <TableRow>
                  <TableCell colSpan={2} className="text-center text-muted-foreground">
                    No attendance in this period.
                  </TableCell>
                </TableRow>
              )}
              {data.member_wise.map((row) => (
                <TableRow key={row.member_code}>
                  <TableCell>
                    {row.member} ({row.member_code})
                  </TableCell>
                  <TableCell>{row.visits}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}

function TrainersReportTab() {
  const { data, isLoading } = useTrainerReport();

  if (isLoading || !data) return <Skeleton className="h-64 w-full" />;

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <ExportButtons report="trainers" />
      </div>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Trainer</TableHead>
            <TableHead>Assigned Members</TableHead>
            <TableHead>Workout Plans Created</TableHead>
            <TableHead>Diet Plans Created</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((row) => (
            <TableRow key={row.trainer}>
              <TableCell>{row.trainer}</TableCell>
              <TableCell>{row.assigned_members}</TableCell>
              <TableCell>{row.workout_plans_created}</TableCell>
              <TableCell>{row.diet_plans_created}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function SalesReportTab({ range }: { range: { from: string; to: string } }) {
  const { data, isLoading } = useSalesReport(range);

  if (isLoading || !data) return <Skeleton className="h-64 w-full" />;

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <ExportButtons report="sales" range={range} />
      </div>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Leads</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{data.summary.leads}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Conversion Rate</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">
            {data.summary.conversion_rate}%
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Trials</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">{data.summary.trials}</CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm text-muted-foreground">Trial Conversion</CardTitle>
          </CardHeader>
          <CardContent className="text-2xl font-bold">
            {data.summary.trial_conversion_rate}%
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Revenue by Plan</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Plan</TableHead>
                <TableHead>Sold</TableHead>
                <TableHead>Estimated Revenue</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.revenue_by_plan.map((row) => (
                <TableRow key={row.plan}>
                  <TableCell>{row.plan}</TableCell>
                  <TableCell>{row.sold_count}</TableCell>
                  <TableCell>₹{row.estimated_revenue.toLocaleString("en-IN")}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
