import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Datin Web",
  description: "Datin web application",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
