"use client";

import { useEffect, useRef, useState } from "react";
import { Html5Qrcode } from "html5-qrcode";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useScanQrAttendance } from "@/hooks/use-attendance";
import { toast } from "sonner";

const SCANNER_ELEMENT_ID = "qr-scanner-region";

export function QrScanner() {
  const [isScanning, setIsScanning] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const scanAttendance = useScanQrAttendance();

  useEffect(() => {
    return () => {
      void scannerRef.current?.stop().catch(() => undefined);
    };
  }, []);

  async function startScanning() {
    setIsScanning(true);
    const scanner = new Html5Qrcode(SCANNER_ELEMENT_ID);
    scannerRef.current = scanner;

    try {
      await scanner.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 250, height: 250 } },
        (decodedText) => void handleScan(decodedText),
        undefined,
      );
    } catch {
      toast.error("Could not access camera. Check browser permissions.");
      setIsScanning(false);
    }
  }

  async function stopScanning() {
    try {
      await scannerRef.current?.stop();
    } catch {
      // Scanner may already be stopped; ignore.
    }
    setIsScanning(false);
  }

  async function handleScan(qrToken: string) {
    if (isProcessing) return;
    setIsProcessing(true);

    try {
      const result = await scanAttendance.mutateAsync(qrToken);
      toast.success(
        `${result.member.full_name} checked in. Membership valid until ${result.membership_end_date}.`,
      );
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to mark attendance.";
      toast.error(message);
    } finally {
      // Brief cooldown so the same code isn't re-processed while still in frame.
      setTimeout(() => setIsProcessing(false), 2000);
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Scan Member QR Code</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div
          id={SCANNER_ELEMENT_ID}
          className="mx-auto max-w-sm overflow-hidden rounded-lg bg-muted"
          style={{ minHeight: isScanning ? undefined : "0" }}
        />
        <div className="flex justify-center">
          {isScanning ? (
            <Button variant="outline" onClick={() => void stopScanning()}>
              Stop Scanning
            </Button>
          ) : (
            <Button onClick={() => void startScanning()}>Start Camera</Button>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
