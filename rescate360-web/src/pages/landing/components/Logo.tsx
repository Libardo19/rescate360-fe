export default function Logo({ className = 'h-9' }: { className?: string }) {
  return (
    <span className="flex items-center gap-2">
      <img src="/logoRescate.png" alt="" className={className} />
      <span className="text-2xl font-extrabold tracking-wide">
        RESCATE<span className="text-brand">360</span>
      </span>
    </span>
  )
}